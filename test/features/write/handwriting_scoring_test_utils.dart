import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jpstudy/features/write/services/kanji_stroke_template_service.dart';

typedef StrokePath = List<Offset>;
typedef StrokeSequence = List<StrokePath>;

Map<String, List<KanjiStrokeTemplate>> loadTemplatesByQuality({
  int maxPerQuality = 0,
}) {
  final raw = File('assets/data/support/kanji/stroke_templates.json')
      .readAsStringSync()
      .replaceFirst('\uFEFF', '');
  final decoded = (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
  final byQuality = <String, List<KanjiStrokeTemplate>>{};
  for (final entry in decoded) {
    final template = KanjiStrokeTemplate.fromJson(entry);
    final key = template.normalizedQuality;
    byQuality.putIfAbsent(key, () => <KanjiStrokeTemplate>[]).add(template);
  }

  if (maxPerQuality > 0) {
    for (final key in byQuality.keys.toList()) {
      if (byQuality[key]!.length > maxPerQuality) {
        byQuality[key] = byQuality[key]!.sublist(0, maxPerQuality);
      }
    }
  }
  return byQuality;
}

StrokeSequence buildStrokesFromTemplate(
  KanjiStrokeTemplate template, {
  double canvas = 220,
  double margin = 20,
  double scaleX = 1.0,
  double scaleY = 1.0,
  Offset translate = Offset.zero,
  bool mirrorX = false,
  bool mirrorY = false,
  bool reverseDirection = false,
  List<int>? order,
  double jitter = 0.0,
  int seed = 0,
}) {
  final base = canvas - (margin * 2);
  final random = Random(seed);

  Offset mapPoint(Point<double> point) {
    var x = point.x;
    var y = point.y;
    if (mirrorX) x = 1 - x;
    if (mirrorY) y = 1 - y;
    x = ((x - 0.5) * scaleX) + 0.5;
    y = ((y - 0.5) * scaleY) + 0.5;
    x = x.clamp(0.0, 1.0);
    y = y.clamp(0.0, 1.0);
    return Offset(margin + (x * base), margin + (y * base)) + translate;
  }

  final indices = order ?? List<int>.generate(template.strokes.length, (i) => i);
  final strokes = <StrokePath>[];
  for (final idx in indices) {
    final spec = template.strokes[idx];
    var start = mapPoint(spec.start);
    var end = mapPoint(spec.end);
    if (reverseDirection) {
      final tmp = start;
      start = end;
      end = tmp;
    }
    final path = _linePath(start, end);
    if (jitter > 0) {
      strokes.add(
        path
            .map(
              (p) => Offset(
                p.dx + ((random.nextDouble() * 2 - 1) * jitter),
                p.dy + ((random.nextDouble() * 2 - 1) * jitter),
              ),
            )
            .toList(),
      );
    } else {
      strokes.add(path);
    }
  }
  return strokes;
}

Map<String, StrokeSequence> buildRegressionNegativeCases(
  KanjiStrokeTemplate template,
) {
  final base = buildStrokesFromTemplate(template, jitter: 0.4, seed: 11);
  final center = const Offset(110, 110);
  final len = base.length;
  final hasPair = len >= 2;
  final hasMid = len >= 3;

  StrokeSequence reorder(List<int> order) => [for (final i in order) [...base[i]]];

  StrokeSequence reverseEach(StrokeSequence source) =>
      [for (final stroke in source) stroke.reversed.toList()];

  StrokeSequence mapPoints(
    StrokeSequence source,
    Offset Function(Offset point) mapper,
  ) {
    return source
        .map((stroke) => stroke.map(mapper).toList(growable: false))
        .toList(growable: false);
  }

  StrokeSequence dropLast(StrokeSequence source) => source.sublist(0, max(1, source.length - 1));

  StrokeSequence addExtra(StrokeSequence source) => [
        ...source.map((stroke) => [...stroke]),
        _linePath(const Offset(35, 180), const Offset(180, 35)),
      ];

  StrokeSequence zigzag(int count) {
    return List<StrokePath>.generate(
      count,
      (index) => [
        Offset(30 + (index * 8), 30 + ((index % 2 == 0) ? 0 : 15)),
        Offset(190 - (index * 5), 90 + ((index % 2 == 0) ? 25 : -20)),
        Offset(40 + (index * 6), 180 - ((index % 2 == 0) ? 15 : 0)),
      ],
    );
  }

  StrokeSequence randomNoise(int count, int seed) {
    final random = Random(seed);
    return List<StrokePath>.generate(count, (_) {
      final pointCount = 4 + random.nextInt(4);
      return List<Offset>.generate(
        pointCount,
        (_) => Offset(
          18 + (random.nextDouble() * 184),
          18 + (random.nextDouble() * 184),
        ),
      );
    });
  }

  StrokePath zeroLengthStroke(Offset anchor) {
    return List<Offset>.filled(9, anchor);
  }

  return <String, StrokeSequence>{
    'order_reverse_all': reorder(List<int>.generate(base.length, (i) => base.length - 1 - i)),
    'order_swap_first_two': reorder(_swapOrder(base.length, 0, 1)),
    'order_swap_mid': reorder(hasMid ? _swapOrder(base.length, 1, 2) : _rotateLeft(base.length)),
    'order_rotate_left': reorder(_rotateLeft(base.length)),
    'order_rotate_right': reorder(_rotateRight(base.length)),
    'order_rotate_two': reorder(_rotateBy(base.length, 2)),
    'order_rotate_three': reorder(_rotateBy(base.length, 3)),
    'order_scramble_far': reorder(_farOrder(base.length)),
    'order_even_odd': reorder(_evenOddOrder(base.length)),
    'direction_reverse_all': reverseEach(base),
    'direction_reverse_first':
        hasPair
            ? [
                base[0].reversed.toList(),
                ...base.sublist(1).map((stroke) => [...stroke]),
              ]
            : reverseEach(base),
    'direction_reverse_last':
        hasPair
            ? [
                ...base.sublist(0, base.length - 1).map((stroke) => [...stroke]),
                base.last.reversed.toList(),
              ]
            : reverseEach(base),
    'mirror_horizontal': mapPoints(base, (p) => Offset((center.dx * 2) - p.dx, p.dy)),
    'mirror_vertical': mapPoints(base, (p) => Offset(p.dx, (center.dy * 2) - p.dy)),
    'shape_scale_wide': mapPoints(base, (p) => _scaleAround(p, center, 1.7, 0.58)),
    'shape_scale_tall': mapPoints(base, (p) => _scaleAround(p, center, 0.58, 1.7)),
    'shape_too_small': mapPoints(base, (p) => _scaleAround(p, center, 0.2, 0.2)),
    'shape_too_large': mapPoints(base, (p) => _scaleAround(p, center, 1.85, 1.85)),
    'shape_off_center_left': mapPoints(base, (p) => p + const Offset(-62, 0)),
    'shape_off_center_right': mapPoints(base, (p) => p + const Offset(62, 0)),
    'shape_off_center_up': mapPoints(base, (p) => p + const Offset(0, -62)),
    'shape_off_center_down': mapPoints(base, (p) => p + const Offset(0, 62)),
    'shape_diagonal_shift': mapPoints(base, (p) => p + const Offset(45, -45)),
    'endpoint_shift_start': [
      [
        base[0].first + const Offset(56, -56),
        ...base[0].skip(1),
      ],
      ...base.sublist(1).map((stroke) => [...stroke]),
    ],
    'endpoint_shift_end': [
      [
        ...base[0].sublist(0, base[0].length - 1),
        base[0].last + const Offset(-56, 56),
      ],
      ...base.sublist(1).map((stroke) => [...stroke]),
    ],
    'endpoint_first_zero_length': [
      zeroLengthStroke(base[0].first),
      ...base.sublist(1).map((stroke) => [...stroke]),
    ],
    'endpoint_all_zero_length': [
      for (final stroke in base) zeroLengthStroke(stroke.first),
    ],
    'endpoint_corner_snap': [
      for (var i = 0; i < base.length; i++)
        _linePath(
          Offset(24 + (i * 3), 24 + (i * 2)),
          Offset(196 - (i * 2), 196 - (i * 3)),
        ),
    ],
    'endpoint_cross_pair': [
      if (hasPair) ...[
        [...base[1]],
        [...base[0]],
        ...base.sublist(2).map((stroke) => [...stroke]),
      ] else ...[
        ...reverseEach(base),
      ],
    ],
    'missing_stroke': dropLast(base),
    'missing_two_strokes': base.sublist(0, max(1, base.length - 2)),
    'single_stroke_only': [base.first],
    'extra_stroke': addExtra(base),
    'shape_zigzag_noise': zigzag(base.length),
    'shape_zigzag_with_extra': zigzag(base.length + 1),
    'shape_noise_random_1': randomNoise(base.length, 401),
    'shape_noise_random_2': randomNoise(base.length + 1, 402),
    'shape_noise_random_3': randomNoise(base.length + 2, 403),
    'shape_noise_random_4': randomNoise(base.length + 2, 404),
    'shape_noise_random_5': randomNoise(base.length + 3, 405),
  };
}

StrokePath _linePath(
  Offset start,
  Offset end, {
  int points = 9,
}) {
  return List<Offset>.generate(points, (i) {
    final t = points <= 1 ? 1.0 : i / (points - 1);
    return Offset(
      start.dx + ((end.dx - start.dx) * t),
      start.dy + ((end.dy - start.dy) * t),
    );
  });
}

Offset _scaleAround(Offset point, Offset center, double sx, double sy) {
  return Offset(
    center.dx + ((point.dx - center.dx) * sx),
    center.dy + ((point.dy - center.dy) * sy),
  );
}

List<int> _swapOrder(int length, int a, int b) {
  final order = List<int>.generate(length, (i) => i);
  if (length <= 1 || a < 0 || b < 0 || a >= length || b >= length || a == b) {
    return order;
  }
  final temp = order[a];
  order[a] = order[b];
  order[b] = temp;
  return order;
}

List<int> _rotateLeft(int length) {
  if (length <= 1) return List<int>.generate(length, (i) => i);
  return [
    ...List<int>.generate(length - 1, (i) => i + 1),
    0,
  ];
}

List<int> _rotateRight(int length) {
  if (length <= 1) return List<int>.generate(length, (i) => i);
  return [
    length - 1,
    ...List<int>.generate(length - 1, (i) => i),
  ];
}

List<int> _rotateBy(int length, int shift) {
  if (length <= 1) return List<int>.generate(length, (i) => i);
  final normalized = shift % length;
  return List<int>.generate(length, (i) => (i + normalized) % length);
}

List<int> _farOrder(int length) {
  if (length <= 2) return List<int>.generate(length, (i) => length - 1 - i);
  final order = <int>[];
  var left = 0;
  var right = length - 1;
  while (left <= right) {
    order.add(right);
    if (left != right) {
      order.add(left);
    }
    left += 1;
    right -= 1;
  }
  return order;
}

List<int> _evenOddOrder(int length) {
  final evens = <int>[];
  final odds = <int>[];
  for (var i = 0; i < length; i++) {
    if (i.isEven) {
      evens.add(i);
    } else {
      odds.add(i);
    }
  }
  return [...odds, ...evens];
}
