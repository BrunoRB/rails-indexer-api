# Indexer

Rails-API toy project.

## Design & Running

Two entities: "Pages" & "Indexeds":
 - "pages" have a URL (unique).
 - "indexeds" have a type ("h[X]" or link), content and a pointer to the origin "page"/url (foreign key).

Run with

`bundle`

then

 `bin/rails server`


To list the indexed pages:

    curl -i -H "Accept: application/vnd.api+json" http://localhost:3000/pages

To list the indexed resources (tags/links) and their respective URLs:

    curl -i -H "Accept: application/vnd.api+json" http://localhost:3000/indexeds

To list the indexed resources (tags/links) with their respective URLs and the associated "page":

    curl -i -H "Accept: application/vnd.api+json" http://localhost:3000/indexeds?include=pages

To index the contents of a given URL:

    curl -i -H "Accept: application/vnd.api+json" -H 'Content-Type:application/vnd.api+json' -X POST -d '{"data": {"type":"pages", "attributes":{"url": "https://brunorb.com"}}}' http://localhost:3000/pages

Change "https://brunorb.com" to any desired URL. The behavior is as follows:

  - if the "page"/URL doesn't yet exist in the database then create a new Page row, fetch the URL data, parse it, extract the content from all links and relevant tags, then store them in new "Indexeds" rows.
  - if you already made a request to the "page"/URL before then all of its associated "Indexed" rows will be deleted and replaced with new ones from the fresh parsed html (basically an update).
  - everything runs under a transaction and the inserts are performed in bulk, so it should be fast even for heavy pages and you won't experience failures leaving a page/URL without associated indexed resources.

## Tests

    bin/rails test test/controllers/indexer_controller_test.rb