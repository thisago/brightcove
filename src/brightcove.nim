import std/asyncdispatch
from std/httpclient import newAsyncHttpClient, getContent, close, newHttpHeaders
from std/strformat import fmt
from std/json import parseJson, `{}`, getStr, hasKey, items, getInt

from pkg/util/forStr import between

using
  accountId: string
  videoId: string

proc getPolicyKey*(accountId): Future[string] {.async.} =
  let
    client = newAsyncHttpClient()
    code = await client.getContent(fmt"https://players.brightcove.net/{accountId}/BJ40wRBYx_default/index.min.js")
  close client
  result = code.between("policyKey:\"", "\"")

proc getVideoSrc*(accountId; videoId): Future[string] {.async.} =
  ## Returns the raw URL of video
  let
    policyKey = await accountId.getPolicyKey
    client = newAsyncHttpClient(headers = newHttpHeaders({
      "Accept": fmt"application/json;pk={policyKey}"
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
    "6074522298001"
  )
