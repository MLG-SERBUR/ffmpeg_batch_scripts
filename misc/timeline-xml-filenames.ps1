[xml]$xml = Get-Content "Timeline 1.xml"
$xml.xmeml.sequence.media.video.track.clipitem.file | ForEach-Object {
    $_.pathurl -replace "file://localhost/", "" -replace "%20", " "
} | Set-Content "clip_list.txt"
