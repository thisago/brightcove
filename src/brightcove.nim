import std/asyncdispatch
from std/httpclient import newAsyncHttpClient, getContent, close, newHttpHeaders
from std/strformat import fmt
from std/json import parseJson, `{}`, getStr, hasKey, items, getInt

proc getVideoSrc*(accountId, videoId, auth: string): Future[string] {.async.} =
  ## Returns the raw URL of video
  let
    client = newAsyncHttpClient(headers = newHttpHeaders({
      "Accept": fmt"application/json;pk={auth}"
    }))
    json = parseJson await client.getContent(fmt"https://edge.api.brightcove.com/playback/v1/accounts/{accountId}/videos/{videoId}")
  close client

  var
    larger = (index: -1, size: 0)
    i = 0
  let sources = json{"sources"}
  for src in sources:
    if src.hasKey "size":
      let size = src{"size"}.getInt
      if size > larger.size:
        larger = (i, size)
    inc i

  result = sources{larger.index}{"src"}.getStr

when isMainModule:
  echo waitFor getVideoSrc(
    "2254903862001",
    "6074522298001",
    "BCpkADawqM2iVmbj6Ef14b290asAezKGw5FFxpgwiT1qkQpntKWppmes46hS9oSHBmrtDxz8vTvtsYSCNoAdpAevatZHGRrxOBmNi-2HzEPT-85YWQj-IkhohWV5oHBr6mVrSVQLhfRPFeBp"
  )
