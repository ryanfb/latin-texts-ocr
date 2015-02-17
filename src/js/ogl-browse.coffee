---
---

files = []

add_archive_file = (identifier) ->
  console.log('add archive file: ' + identifier)
  archive_link = $('<a>').attr('href',"https://archive.org/details/#{identifier}").attr('target','_blank').text(identifier + ' on archive.org')
  file_li = $("##{identifier}")
  file_li.append($('<p>').append(archive_link))
  loader = ($('<div>').attr('class','ui active mini loader'))
  file_li.append(loader)
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
          file_li.append($('<p>').text(data[key]))

build_interface = ->
  file_list = $('<ul>').attr('id','file_list').attr('class','list-group')
  $('#content').append(file_list)
  # files = _.sortBy(files, (file) -> file.updated_at).reverse()
  for file in files
    ocr_identifier = file.name.replace(/-OCR\.txt$/,'')
    file_link = $('<a>').attr('href',file.html_url).attr('target','_blank').text(file.name)
    file_li = $('<li>').attr('id',ocr_identifier).attr('class','list-group-item')
    file_li.append(file_link)
    file_list.append(file_li)
    add_archive_file(ocr_identifier)

grab_file_page = (url, callback) ->
  console.log('grab_file_page: ' + url)
  $.ajax url,
    type: 'GET'
    dataType: 'json'
    crossDomain: 'true'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('AJAX error')
    success: (data, textStatus, jqXHR) ->
      files = files.concat(data)
      console.log(jqXHR.getResponseHeader('Link'))
      if jqXHR.getResponseHeader('Link')
        links = jqXHR.getResponseHeader('Link').split(',')
        next = (link.split(';')[0] for link in links when link.split(';')[1] is ' rel="next"')
        if next.length > 0
          grab_file_page(next[0][1..-2], callback)
        else
          callback()
      else # last page
        callback()

$(document).ready ->
  console.log('ready')
  grab_file_page('https://api.github.com/repos/ryanfb/latin-texts-ocr/contents/ocr-results?per_page=100', build_interface)
