function showButton(res) {
  var lastItem
    , items = res.data
    , anchors = document.getElementsByTagName("a")
    , i
    ;

  for(
    i = 0;
    item = items[i++];
    lastItem = !lastItem || lastItem.id<item.id ? item : lastItem
  );
      
  for(i = 0; item = anchors[i++];)
    if(item.getAttribute("rel") == "download")
      item.href = lastItem.html_url;

  console.log(lastItem);

  document.getElementById("archive-name").innerText = lastItem.name;
  document.getElementById("archive-size").innerText = (lastItem.size/1024)+"KB";
  document.getElementById("archive-uploaded").innerText = "Uploaded at " + relativeDate(lastItem.created_at, new Date);
  
}