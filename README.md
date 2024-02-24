A sample command-line application with an entrypoint in `bin/`, library code
in `lib/`, and example unit test in `test/`.

Pattern p = RegExp(r'(\w+)-\n(\w+)');
Iterable<Match> m = p.allMatches(text);
print(m.map((e) => e.group(0)));
