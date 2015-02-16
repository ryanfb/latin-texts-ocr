---
---

repos = []

add_hathitrust_repo = (repo_li_id, identifier) ->
  console.log('add hathitrust repo: ' + identifier)
  repo_li = $("##{repo_li_id}")
  loader = ($('<div>').attr('class','ui active mini loader'))
  repo_li.append(loader)
  $.ajax "http://catalog.hathitrust.org/api/volumes/htid/#{identifier}.json",
    type: 'GET'
    dataType: 'json'
    crossDomain: 'true'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('AJAX error')
      loader.remove()
    success: (data, textStatus, jqXHR) ->
      console.log('hathitrust success for ' + identifier)
      console.log(data)
      console.log(data.records.length)
      loader.remove()

add_archive_repo = (repo_li_id, identifier) ->
  console.log('add archive repo: ' + identifier)
  # $.ajax "https://archive.org/details/#{identifier}&output=json",
  archive_link = $('<a>').attr('href',"https://archive.org/details/#{identifier}").attr('target','_blank').text(identifier + ' on archive.org')
  repo_li = $("##{repo_li_id}")
  repo_li.append($('<p>').append(archive_link))
  loader = ($('<div>').attr('class','ui active mini loader'))
  repo_li.append(loader)
 
  $.ajax "https://openlibrary.org/ia/#{identifier}.json",
    type: 'GET'
    dataType: 'json'
    crossDomain: 'true'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('AJAX error')
      loader.remove()
    success: (data, textStatus, jqXHR) ->
      # console.log('archive success for ' + identifier)
      # console.log(data)
      loader.remove()
      for key in ['title','subtitle','by_statement','publish_date','publishers','publish_places']
        if data[key]
          repo_li.append($('<p>').text(data[key]))

build_interface = ->
  repo_list = $('<ul>').attr('id','repo_list').attr('class','list-group')
  $('#content').append(repo_list)
  ocr_pattern = /.?201\d+-\d\d-\d\d-\d\d-\d\d.?/
  scan_pattern = /_.*$/
  for repo in repos
    repo_url_fragment = _.last(repo.html_url.split('/'))
    if repo_url_fragment.match(ocr_pattern)
      ocr_identifier = repo_url_fragment.replace(ocr_pattern,'').replace(scan_pattern,'')
      repo_link = $('<a>').attr('href',repo.html_url).attr('target','_blank').text(repo_url_fragment)
      repo_li_id = repo_url_fragment.replace(/\./g,'_')
      repo_li = $('<li>').attr('id',repo_li_id).attr('class','list-group-item')
      repo_li.append(repo_link)
      repo_list.append(repo_li)
      if ocr_identifier.match(/\./) # hathitrust
        # disable calls to hathitrust until CORS is enabled
        # add_hathitrust_repo(repo_li_id, ocr_identifier)
      else # archive.org
        add_archive_repo(repo_li_id, ocr_identifier)

grab_repo_page = (url, callback) ->
  console.log('grab_repo_page: ' + url)
  $.ajax url,
    type: 'GET'
    dataType: 'json'
    crossDomain: 'true'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('AJAX error')
    success: (data, textStatus, jqXHR) ->
      console.log('AJAX success')
      console.log(jqXHR.getResponseHeader('Link'))
      links = jqXHR.getResponseHeader('Link').split(',')
      next = (link.split(';')[0] for link in links when link.split(';')[1] is ' rel="next"')
      console.log(next)
      console.log(data)
      repos = repos.concat(data)
      if next.length > 0
        grab_repo_page(next[0][1..-2], callback)
      else # last page
        callback()

$(document).ready ->
  console.log('ready')
  grab_repo_page('https://api.github.com/users/OpenGreekAndLatin/repos?per_page=100', build_interface)
