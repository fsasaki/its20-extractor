wikipedia-extractor
===============

XSLT Stylesheet to convert wikipedia pages into NIF, interpreting links from within paragraph content to other wikipedia pages as ITS 2.0 'Text Analysis' entity type / concept class information.

Usage
-----

* Convert a wikipedia page into wellformed XML, e.g. via HTML tidy

* Use an XSLT 2.0 processor (e.g. Saxon) to convert the page to NIF. For this step, provide two parameters:

1. base-uri: provides the URI of the wikipedia page or the resource on dbpedia.

2. dbpediaPrefix: provides the dbpedia prefix for the generated entity type / concept class information.

A sample transformation including an online HTML tidy tool is available: http://tinyurl.com/n6ykjwr