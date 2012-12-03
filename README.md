# Stupid parser

## How to use

1. Put your parsing into ./lib/parser.rb 
2. Put yor xml structure into ./lib/saver.rb
3. Put yor proxy list into, hmm, proxy_list.txt
4. Run `ruby runner.rb your_uri start stop save_method`

Uri format: `http://www.example.com/{x}/foobar`, where {x} - place substitution.

Save methods: xml, csv, all

## To do list

* Add TOR support.
* Add tests.

## Problems

* Stupid test don't work correctly.
* I'm too lazy to fix bugs.
