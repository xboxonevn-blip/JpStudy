const fs = require('fs');
const path = require('path');

const root = path.join('assets', 'data', 'content');
const outPath = path.join(root, 'index.json');

function jsonFiles(dir) {
  if (!fs.existsSync(dir)) return [];
  const out = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      out.push(...jsonFiles(full));
    } else if (entry.name.endsWith('.json')) {
      out.push(full);
    }
  }
  return out.sort();
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

function levelFromPath(file) {
  const parts = file.split(path.sep);
  const index = parts.indexOf('content');
  if (index === -1 || index + 2 >= parts.length) return null;
  const level = parts[index + 2].toUpperCase();
  return /^N[1-5]$/.test(level) ? level : null;
}

function entryCount(payload) {
  if (Array.isArray(payload)) return payload.length;
  if (payload && Array.isArray(payload.entries)) return payload.entries.length;
  return 0;
}

function grammarExampleCount(payload) {
  if (payload && !Array.isArray(payload) && Array.isArray(payload.examples)) {
    return payload.examples.length;
  }
  if (Array.isArray(payload)) {
    return payload.reduce((sum, item) => {
      if (item && Array.isArray(item.examples)) return sum + item.examples.length;
      return sum + 1;
    }, 0);
  }
  return 0;
}

function addLevel(levels, level, entries) {
  levels[level] ??= { files: 0, entries: 0 };
  levels[level].files += 1;
  levels[level].entries += entries;
}

function orderedLevels(levels) {
  const out = {};
  for (const level of ['N5', 'N4', 'N3', 'N2', 'N1']) {
    if (levels[level]) out[level] = levels[level];
  }
  return out;
}

function lessonDataset(dataset, countFn = entryCount) {
  const files = jsonFiles(path.join(root, dataset)).filter(levelFromPath);
  const levels = {};
  let entries = 0;
  for (const file of files) {
    const count = countFn(readJson(file));
    entries += count;
    addLevel(levels, levelFromPath(file), count);
  }
  return { files: files.length, entries, levels: orderedLevels(levels) };
}

function vocabDataset() {
  const files = jsonFiles(path.join(root, 'vocab')).filter(levelFromPath);
  const levels = {};
  const series = {};
  let entries = 0;
  for (const file of files) {
    const payload = readJson(file);
    const count = entryCount(payload);
    entries += count;
    addLevel(levels, levelFromPath(file), count);
    if (count > 0) {
      const seriesName =
        payload.series || path.basename(path.dirname(file)) || 'unknown';
      series[seriesName] = (series[seriesName] || 0) + count;
    }
  }
  return {
    files: files.length,
    entries,
    levels: orderedLevels(levels),
    series: Object.fromEntries(Object.entries(series).sort()),
  };
}

function immersionDataset() {
  const files = jsonFiles(path.join(root, 'immersion')).filter(levelFromPath);
  const levels = {};
  for (const file of files) {
    addLevel(levels, levelFromPath(file), 1);
  }
  return {
    files: files.length,
    entries: files.length,
    levels: orderedLevels(levels),
  };
}

function kanaDataset() {
  const payload = readJson(path.join(root, 'kana', 'kana_chart.json'));
  const scripts = payload.scripts || {};
  const summary = {};
  let entries = 0;
  let compounds = 0;
  for (const [script, data] of Object.entries(scripts)) {
    const scriptEntries = Array.isArray(data.entries) ? data.entries.length : 0;
    const scriptCompounds = Array.isArray(data.compounds)
      ? data.compounds.length
      : 0;
    entries += scriptEntries;
    compounds += scriptCompounds;
    summary[script] = { entries: scriptEntries, compounds: scriptCompounds };
  }
  return { entries, compounds, scripts: summary };
}

function hanVietOnRulesDataset() {
  const payload = readJson(path.join(root, 'kanji', 'han_viet_on_rules.json'));
  return {
    rules: Array.isArray(payload.rules) ? payload.rules.length : 0,
    sources: Array.isArray(payload.sources) ? payload.sources.length : 0,
    sourcePolicy: payload.sourcePolicy || {},
  };
}

const index = {
  schemaVersion: 3,
  generatedAt: new Date().toISOString().slice(0, 10),
  datasets: {
    vocab: vocabDataset(),
    kanji: lessonDataset('kanji'),
    grammar: lessonDataset('grammar'),
    grammarExamples: lessonDataset('grammar_examples', grammarExampleCount),
    immersion: immersionDataset(),
    hanVietOnRules: hanVietOnRulesDataset(),
    kana: kanaDataset(),
  },
};

fs.writeFileSync(outPath, `${JSON.stringify(index, null, 2)}\n`, 'utf8');
console.log(`wrote ${outPath}`);
