require 'test_helper'
require 'faker'

# curl -i -H "Accept: application/vnd.api+json" -H 'Content-Type:application/vnd.api+json' -X POST -d '{"data": {"type":"pages", "attributes":{"url": "https://bruno.com"}}}' http://localhost:3000/pages
class IndexedsControllerTest < ActionDispatch::IntegrationTest

  test "should refuse and invalid URL" do
    url = 'htps://' + Faker::Internet.domain_name
    post '/pages',
      params: {:data => {:type => "pageS", :attributes => {:url => url, :pageHTML => ''}}}.to_json,
      headers: { "Content-Type" => "application/vnd.api+json" }
      assert_equal 400, status
  end

  test "should refuse and invalid TYPE" do
    url = 'https://' + Faker::Internet.domain_name
    post '/pages',
      params: {:data => {:type => "pageS", :attributes => {:url => url, :pageHTML => ''}}}.to_json,
      headers: { "Content-Type" => "application/vnd.api+json" }
      assert_equal 400, status
  end

  test "should fetch and parse a valid HTML page" do
    html = '
<!DOCTYPE html lang="en">
<html>
  <head>
    <meta charset="utf-8">
  </head>
  <body>
  <h1>h1 text</h1>
  <div>
    <div>
    <h3>h3 text</h3>
    <div>
    https://brunorb.com
  </div>
  <a href="http://brunorb.com"></a>
  </body>
</html>
    '

    url = 'https://' + Faker::Internet.domain_name
    post '/pages',
      params: {:data => {:type => "pages", :attributes => {:url => url, :pageHTML => html}}}.to_json,
      headers: { "Content-Type" => "application/vnd.api+json" }
      assert_equal 200, status
      assert_equal(
        {
          "data" => {
            "id" => "1", "type" => "pages", "links" => {"self" => "/pages/1"}, "attributes" => {"url" => url}
          }
        },
        response.parsed_body
      )

    p = Page.find(1)
    assert_equal(url, p.url)

    data = {}
    Indexed.all().each do |ind|
      t = ind[:c_type]
      if !data[t]
        data[t] = []
      end
      data[t] << ind[:content]
    end
    assert_equal(1, data['h1'].length)
    assert_equal(1, data['h3'].length)
    assert_equal(2, data['link'].length)
    assert_equal('h1 text', data['h1'].first)
    assert_equal('h3 text', data['h3'].first)
    assert(data['link'].member?('http://brunorb.com'))
    assert(data['link'].member?('https://brunorb.com'))

    get '/indexeds'
    assert_response :success
    assert(response.parsed_body)
    parsedGetBody = JSON.parse(response.parsed_body)
    assert(parsedGetBody.key?('data'))

    data = {}
    parsedGetBody['data'].each do |d|
      assert_equal('indexeds', d['type'])
      assert(d['attributes'])

      t = d['attributes']['c-type']
      if !data[t]
        data[t] = []
      end
      data[t] << d['attributes']['content']
    end
    assert_equal(1, data['h1'].length)
    assert_equal(1, data['h3'].length)
    assert_equal(2, data['link'].length)
    assert_equal('h1 text', data['h1'].first)
    assert_equal('h3 text', data['h3'].first)
    assert(data['link'].member?('http://brunorb.com'))
    assert(data['link'].member?('https://brunorb.com'))
  end

end
