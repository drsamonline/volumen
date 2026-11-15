# Open questions

1. **How much `libcss` is enough?** Guess: display role, width hint and order key are
   enough for 80% of the readability win. Settled by: W4 on the corpus.
2. **Should `--format=json` include the raw text of every block?** Guess: yes, always -
   consumers should never need to re-fetch. Settled by: size measurements on the corpus.
3. **Is ncurses or slang the better default in 2026?** Guess: ncurses, for wide
   availability. Settled by: a build matrix.
4. **Can the structure tree be built without touching `HTML.c`?** Guess: no, the
   callbacks are the only place the information exists. Settled by: W2 spike.
5. **Does batch mode need a persistent connection pool across URLs?** Guess: yes for
   same-host batches, which is most batches. Settled by: the 100-URL bench.
