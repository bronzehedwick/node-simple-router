# Router object, invocation returns a function meant to dispatch  http requests.
Router = (options = {}) ->

# Required modules, all of them from standard node library, no external dependencies.	

  urlparse = require('url').parse
  querystring = require('querystring')
  fs       = require('fs')
  path_tools = require('path')
  spawn  = require('child_process').spawn
  domain = require 'domain'
  net = require 'net'
  http = require 'http'
      
# End of required modules


# Constants.	

  default_options =
    version: '0.7.1-3'
    logging: true
    log: console.log
    static_route: "#{process.cwd()}/public"
    serve_static: true
    list_dir: true
    default_home: ['index.html', 'index.htm', 'default.htm']
    cgi_dir: "cgi-bin"
    serve_cgi: true
    serve_php: true
    php_cgi: "php-cgi"
    served_by: 'Node Simple Router'
    software_name: 'node-simple-router'
    admin_user: 'admin'
    admin_pwd: 'admin'

  mime_types =
    '':      'application/octet-stream'
    '.bin':   'application/octet-stream'
    '.com':   'application/x-msdownload'
    '.exe':   'application/x-msdownload'
    '.htm':  'text/html'
    '.html': 'text/html'
    '.txt':  'text/plain'
    '.css':  'text/css'
    '.mid':  'audio/midi'
    '.midi': 'audio/midi'
    '.wav':  'audio/x-wav'
    '.mp3':  'audio/mpeg'
    '.ogg':  'audio/ogg'
    '.mp4':  'video/mp4'
    '.mpeg': 'video/mpeg'
    '.avi':  'video/x-msvideo'
    '.pct':  'image/pict'
    '.pic':  'image/pict'
    '.pict': 'image/pict'
    '.ico' : 'image/x-icon'
    '.jpg':  'image/jpg'
    '.jpeg': 'image/jpg'
    '.png':  'image/png'
    '.gif' : 'image/gif'
    '.pcx':  'image/x-pcx'
    '.tiff': 'image/tiff'
    '.svg':  'image/svg+xml'
    '.xul':  'text/xul'
    '.rtf':  'application/rtf'
    '.xls':  'application/vnd.ms-excel'
    '.xml':  'application/xml'
    '.doc':  'application/msword'
    '.pdf':  'application/pdf'
    '.mobi': 'application/x-mobipocket-ebook'
    '.epub': 'application/epub+zip'
    '.js':   'application/x-javascript'
    '.json': 'application/json'
    '.sh':   'text/x-sh'
    '.py':   'text/x-python'
    '.rb':   'text/x-ruby'
    '.c':    'text/x-csrc'
    '.cpp':  'text/x-c++src'


  escaped_icon = '%89PNG%0D%0A%1A%0A%00%00%00%0DIHDR%00%00%002%00%00%00%25%08%06%00%00%00%00%EC%BA%92%00%00%00%04gAMA%00%00%B1%8F%0B%FCa%05%00%00%00%20cHRM%00%00z%26%00%00%80%84%00%00%FA%00%00%00%80%E8%00%00u0%00%00%EA%60%00%00%3A%98%00%00%17p%9C%BAQ%3C%00%00%00%06bKGD%00%FF%00%FF%00%FF%A0%BD%A7%93%00%00%00%09pHYs%00%00%27%3A%00%00%27%3A%01%5D5%BBa%00%00%0C%95IDATX%C3%C5%99%7B%8C%5D%C5y%C0%7F3s%CE%B9%CF%BD%FB%F6%EEzw%CD%FA%01%18pLpDpx%87%A0%26A4%16%A1%01%A9I%AB%145%A5%15%7FT%22%EAKi%DA%A24BQ%1B%9AT%A1%89%13Z%29%0A%A1%10%15%D5n%0A%14%88%C0%01c%BB%3C%16%E4%C4%06%8C%D7%F6z%BD%DE%87%EF%BD%7Bw%F7%EE%7D%9C3%8F%FEq%EF%EE%DE%F5%EE%925Q%DBO%1A%CD%E8%DE93%DFo%E6%FB%BE%F9%E6%1C%C1%05%CB%A5%C0%A8%07%BBZ%E0%E2%7E%E8%DB%0C%9D%97@r%0B%24%07%20%D1%0D%B1V%08%D2%A0%02%90%5E%ED9%AB%C1%84%10%16%A1%3A%05%E5q%28%9D%82%D2q8w%0C%CE%0C%C1%7B%23%B0%B7%00%BD%1A%DE%BD%20%AD%C4%DA%BA9%E0c1%B8%A5%1F.%DF%01%BD%3B%A1c%3B4o%86t+%C4%92%E0y%A0%04%C85%0C%EB%00%0B%18%07ZC%B5%04%C5%29%98%1E%82%ECa%18%3D%04G%07%E1%85%118X%5D%8B%9A%EF%D3%E3f%60%1Fp%FF%3A%B8%EAz%D8t%1B%F4%5C%07m%1B%20%99%04o%ED%EB%B0fq%80%06J%25%C8%9F%86%B1W%E0%C4%D3%F0%E6%7ExhrQ%A7%E5%E2-%FF%A9%1D%C8%01%1B%7B%AE%FC%F0%8E%5DJ%5E%7F%F7%99%D1%CB%3F2W%ECh%AAV%93h%ADX%DB%AA%7F%10%11%F5%B1%13I%A5%BA%B7%C6b%99%AD%E9t%FB%5D%BD%BD%A97%8CqO%1C%3E%3C%B5%17%18%5B%D4q%95%1D%F1%93_%C2%9A%E3%09%3F%FE%3B%B7%19%B7%E3%BE%AB%B6G%D7%7E%E3o%5Bb%89x%9A%B1%B1%90%B3c%9A3g%1C%A3%A306%A6%98%98%94%0C%0FKfg%BBp%CE%07%07%CE%D5%17v%CD%12%D1%D44%C1%C0%80%A5%AB%CB%D2%DDm%E8%EBs%F4%F5I%D6%AF%F7%E8%E9%09%A8T%8A%7C%F9%CBS%D5%C1%C1%E0%00%0C%3E%0C%3Fz%1A%B6%94%E1%07%CB%87%EB%DC%E6H%B4%DF%DF%97%E9%7B%FE%A1%E6%81%89%5C%F3%80q%9D%17%CF%B8%EF%FD%F3q%E7%9Cv5%B1%CE%DA%C8U*%15%97%CFO%BB%DD%3F8%E86%5D%F6%BA%0B%9A%AB.%D6%EC%5C%90v%CEK8%A7%02%E7%A4%E7%9C%90%CE%21%5C%1Do%B5Ru%BD%BD%AF%BB%EF%7E%F7%A0%CB%E5%A6%5D%A5Rq%D6F%CE9%5B%9F%D3%B8%EF%7C%E7%B8%8B%C5f%5C%CD%A7%26r%F0%FCCp%7F_%E3%8A%29%80%0D78%E6%C6%FFzk%A2%ED%B3%FF%104%7D%E4%0B%7E%B2%25%E5%27%04N%05d%F33%DCx%8D%A3%B5%25%09%08%84%90x%9EG%3C%EEc%9DcvN%91-@Y%07%C8@%E1%05%8B%B1Jz%20d%DDZV%D9%8D%AE%AE%02%9F%FA%94%E3%F6%DB%5B%D9%B2%A5%03%CF%F3%11b%D1tO%9C%C8%F3%95%AFD%8C%8C%AC%AB%0F%94J@%F7%D5%D0u%09%7C%FF-%D8%97%85%07P%1D%97%3DL%25%FF%E4E%A9%AE%CF%7E%3B%DE%BC%FDv%3F%19W%5E%1C%BC8%F8qA%A1%E4%D3%92%9A%60c%BF%E0%B57%CFaMDK%26%86%94%8A%DE%F5%CD%7C%E2%A6%14W%EF%98E%A9%2C%E7%0A%86%8A%0E%90%BEB%05%A0%FCz%F1@%A8%1A%94%03%B0%11%5D%5D9%3E%F7%B9%09%BE%F65%C9%BD%F7%F600%D0%8E%10%02k%0D%C7%8F%E7y%E3%8D%2C%A9%94%E1%D1Gs%3C%FEx7%D6%06%8DN%20k%21%BFu%23%FC%E3+%F0%DB%D3%22%D1%7Eu%AA%F3%B2o%3C%18o%D9y%9FP%89ekg-%ACk%3ACO%7B%89%F7F%DA%E8i/%F1%9B7%86%7C%FA%E6V.%EAkAJ%05@%B9%5C%E1%D5%C1%2C%3F%D9%5Bf%DF%C1%16%CE%E5%5B%B1%DA%C3%EA%FA%09%12%81%D3%9A%B6%E6%29n%BD%A9%C0%17%3E%9F%60%E75%1D%24%93%F1%FA%3C%86%93%27%0B%3C%F9%E4%14%8F%3D%160%3C%9Cd%DB%B6%3C%A7O%279%7D%BAo%95%1D-%5B8%F40%FC%D9_%88%BEkw%DF%91%E9%DD%F5%3D/%D1%B5n%A58%E4%1CX%EB%B0%C6%21%90X%E3%90%AE%C4%A6%AE%2C%B7%5D%1B%F1%E9%1BZ%E9%EF%5D%04%CA%E7%0B%3C%F2%E8%7B%EC%7E%BC%8BRu%03%AE%0E%A2C%88%AB%D3%DCw%CF%04%7F%F4%FB%17%D3%D6%D6%B2%00p%EA%D4%3C%80%CF%91%23%1DDQ%B2nZ%B6%5E%BF_%84%9C%98%84%BD%7F%28%B6%DE%F1%E2%9E%A6%9E%EBv%09%E5/%C411%1Fx%EA%11%C89p%B6%5E%9BZ%5Bk%874%256vf%B9mg%C4%27%AEi%26%3B%15%B2%E7g%25%5E%7C-%C3d%AE%0D%13%F9%0B%BBa%23%B0QDgK%9E%5B%AF%9F%E1%EE%3B%92tv%04%FC%E7%D3%D3%FC%F8_%7D%0E%BF%D5AXNr%E1a%3D%02%5E%D9+v%FC%C1/%B3%A9%CE+%DA%11%20%CE%1F%A3%21%B6%60k%00%D6%D6a%0CX%03%3A%AA%01u%A7s%14K%01%93%856%9C%09j%FFG%8B%10%26%AC%B5u%15L%18%D2%D9%92%27%15%0B%19%1Aj%A7%3C%97%C4i%B1%D0%DF%99%0Bd%E1H%CEK%B4%26%DA%E3%CD%8B%3B%28%EA%BB%82%9Bw%CC%86%1D%B1%8B%00%D6%80%D3%E0%1B%81%89R%8C%85%29%90%10%CF%2C%05%90%F5%B6%F4jm%E9%81%F1%03%B2%C5n%C6s%80%0F%B1T%1D%B0%1E%ACLx%A10%89vOz%B3%C4%EA%20%E2%7Cst%CB%21%16@4%18%0D%BA%AA%C9%C4%A6H%8A2%13%B3%ADTu%1A%15%08dX%07%09%EB%CA%AB%C6%C8%E5HzEd%3Cbf6%03%C2%C3%AB%CF%3Fo%15%17%063%8B%A7b%E3%C4%9A%3E%84Pr%19%C8J%26e%CD%22@*%9Cb%FB%FA%02%9F%FCp%9C%DE%8E%24%AF%1C%9E%E4%B9%B7%F2%9C%C8%B6%13%AA%14%C6%135%E5%EB%00B%3A%7CU%E2%8A%8D%E7%D8%F5qMw%BBb%CF%7F%E5%D9w%A0%85l%B6%15%E9%AB%C5y%D7%0Cc%81q%BC%B6-%1E%5E%A2%88%97%C8%2C%804%3A%BB%B3%60%B4%C59%89%AB%03%24%CBS%5C%D6R%E0%D6K%E3%5C%B9%A5%8FT2%01@%7Fw3%5Bz%86%F9%F6%BF%BF%C3%89%E2v%3C%15%D4%00%EA%E3%FA%EE%2Cw%7E%7C%82%DF%FB%AD%0D%F4%F5%B6%01%92%9Bo%28q%E0P%96%C7%9E%2C%B0o%7F%1D%C8S%B5%C5%D3%B5%F9%DF%3F%E5%29%82%F0P7%FE%E5%9F%FC%8D%09C%82T%86%20%25%F1%12%B5%C3%D0%8B%81%8A%81%A4Lw%F9%04J%84%08Wf%5Bb%9C%BB%AF%80%3B%3E%DA%C5%E6%BE%0E%02%DF%C7Z%C3%D9%C9%02O%BD%3A%C1%93%83%3E%A3%D5%0D%A0%E2%9C%1F%81%9C%93D%91%21PU%3A%5B%05%E9T%8CX%2C%60%CB%A6%0C%B7%DE%94%60%FB%E5%D3Da%8E%F1IG%A5*X%D7y%0E%E1%22%AA%D5%C4*%10%1A%21%CE%22D%0C%F1%C7%27%87%9D%D5%1E3%A3%11%A9u%FDH%25%17%FC%C3XGKv%98%7B%06bDV0W%8D%D8%DA%DBN%3A%95%ACm%AA%B5L%E4%A6y%F9%ED%3C%FB%86%14%C33%1DD%26%85%8D%04%A6%0A%A6Z%3B%3F%1A%DBQ%D9%21%A2%22%97tg%F9%CCM%96%DF%B8%B1%9D%9E%AEL%3D-q%CC%CC%94%F8%F9%CB9%7Ey%A4%C2%0D%D7%C5y%F4%D1%12%BBwo%02%17%9C%07a%11r%04%A9%7C%AC%D55%90tw%3F%F9%E3%A7%D1%15A%D3%FA%F5H%CF%C39%D0%D3%B3%DCR%9D%E0%F6%CB7%22%95Z2%CC%D4%F4%0C/%1C%19%E7%E5%D1%18%23%E5v%22%9B%C2%85%02%13%D6%23Pu%B1nl%EB%06%20%A5g%D9%DA%9Bc%D7%AD%8EO%DE%D4%C6%FA%9E%F9%F0%E9p%CE%22%84%E2%B5%D7%C6%B8%EB.%C7%A9S%EB%97%EE%84%3C%8B%0A%1C%CEm%C0F%23%F5tN%082%FD%FD%F8%09%C5%DC%E40%D2+%E1%A5%1C%DDQ%96%9D%BD%ED%0B%10%CEZt%14R%AET8%3B%99%E5%BF%DF%1De%B8%14C%26%D2x%F3%8E-%97%17%CE%AB%85%00%A5%04%9A%0C%83%C7%FA%F9%D6%23%25%9E%7B%E1%1DtT%AD%3B%84@%88%DA%9CW%5D%D5%C1%5Dw%CD%21D%A5%0EQB%F9%C3%F8%29%85%F4%FA%17%CCw%E1b%25%A4%24%DD%BD%9ER%BE%C0%D4%89Q%3Ci%B92*R%AC%269s%F2%0CS%15M%BEl%C8W%1C%F9%B2d%BA%AA%C8%257%A2Ll%21%03XV%7E%85%08@J%83%03%5Ez%AD%99%91%B1Qz%3A%25%5D%9D%8A%AEN%9F%8E%F6%80%D6%D6%18w%DE%19c%CF%9E3%1C%3B%9E%22H%CD%A2b%9D8%DB%82%0D%17%7Dp%E9%0DQ%08b%99V%A4%97%A68%7C%8A%17%C7%A7%D8%3F%A5%A0%B9%0B%E3%B5%A0%8D%8F%B1%12%A3%14%D6%93%D84%A8%BA%C9%D8%C60%BDJ%A1%B1%AE%9FQB%C4%C8%CFm%E3%A9%7D%06%13j%D0%06%CFE%C4TH%3AQ%A6%BD9%C7%BAu%13%C8D%89%D4%BA+%90j%00%AB%03%8C%5D%BA%28KA%EA+%A9%7C%9F%F4E%17%13vl%A0%98%CB%13%E5%E6%80%08%15d%102%85%B3rI%DA%B1%98K%B1%90%ED6%16%A7%1B%B2%01%B3%3C%CD%C1%82@%21%9C%AA%BD%8A%A8D%CC%84%8E%09%5B%E6%A4/%F1Nn%C2%0B%DA%F0%13%09l%B4%F2n%7BV%1BK%E3%D5G%2C%1EH%5E%10%23%D5%D1%83NET%A6%8BT%0A%D3DsY%ACV@%12H%E2l%805%1E6R5%A8%D5%E0V%804%1Ald0%91%C6%EA%10gKHU%22%D6d%90%81%8F%F22@%BA%96%7CF%60L%5D%B7ey%A5%B1%9E%10b%19%DF%7C%BF%F9%FB%B7P%3E%B1L+%7E%BC%95%A8%1C%11%CEU%08g%E6%A8%16s%E8%B2AW%C1%86%0A%13yX%AD%B0%DA%C3D%0A%1BIL%3D%92%99%D0aB%8B%09%EB%8AG%06g4B%19%FC%24%04%29%85Pq%84%E8%C0%B98V%FB%D8%FA%A2%CC%1B%0B%AC%96%1B%0B%E7E%E5r%1E%E8%5C%89d%C9C%F5%24Rz%3E%7E%D2G%F9M%04%190U%83%AEDD%15%8D.G%B5R%890%D5%0A%26%04%A9%1C%D2%07/%26%EA%A6%A5p%D6%C3%B98%CE%FA8%E3a%8D_%5B%80hq7%17%92%D6%F7%05%98%FF%B3%9C%F7%E6%26%27%0E%B4%0Cl%D9%25%F0%7Fu%98i%F0%A3y%F3%13R%21%7D%85%0FHU%CB%08%1AS%F7F%E5%E6M%CD4%FE%07%08%BB%D4%02%D6%A4%C3%82D%C0%C4%01%99%7B%F7%D8%0F%CB%F9%FC%E4%05%DDgV%BA%B45%026%80%BA%86I%9D%5B%AA%AC%5Ba%D85%E9%21%1A%1F%CEO%C2%B1%1F%CA7%FF%E5%91%E7%CE%1D%3D%FADT.%DB%25%F7%90%0F%28%E2%BCzE%8DW%EA%F3%81%A4l%E1%E8%13%CE%3C%F2%9C%FC%D0%E7%BF8w%E2g%CF%7E3%FB%F6%D1gL%18%3A%04%88_%87%E4%FFLB%E7%DC%D1g%9C%7D%F6%9B*%F8%E2%9C%1Az%F6i%EE%3D%B0%7F%FA%D5%7F%DA%3D%1845o%88eZ7%0B%E5Kg%EBq%FF%FC%83%CD%ACr%E0%AD%E5%F7%D5%FA%AC%A1%EF%92%83%D6%94%B4%8D%7E%F1%94%8D%7E%FA%A7%7E%EA%EBC%D1%DCGk/%E8%5E%7C%E0%01%7E%F7%F9%7D%D9C%DFzh%BF%8A%C5%95%9FH_%AA%82D%02%27%96O%FE%FF%04R%CB%0A%2C%26%3A%977%E1%EB%DF7%E1%9E%AF%C62%0F%9E%28%E7j%06%BA%90%D2%BE%FC%F5%07h%BFd%DB%CC%D0%B3%7B_R%B1%C4%3BBx%9D%CAO%F4H/%F0%96%00%FDo%83%AC8%8F%C3%E8%D9%8A%AD%1E%7BYW%7E%FEW%D1%DC%C3%BB%A5J%E7+%85%CF%2C%18%DA%92%DC%7C%F2%17%83D%B3%B3%FA%DD%FFx%FCm%1C%CF9%E7NZm%D3B%FA%EDB%FA1%E1%E4%D2%15Zu%E2%0F%08%B2%0CJc%A2%C2%AC%AE%0C%1D%8CJ%AF%FE%7DX%FC%C9%83%95%C2W_%85Ym%C2%FDK%3CF%9D%EFB%BAR%06%A0%3AS%28%1Eyb%F7%1BV%EBgt%A5%3C%A8%CB%E5%A2%D5%26%E9%ACL%82%F4q%12%9CXUi%FB%01@%ACqX%1Da%A3bIW%C6%86t%E9%9D%BDa%F1%D0%DFU%A7%FF%ED%A1%D2%E4%9F%BF%84+%14%9D%C9%83+/s%FD5E%C0%7B%0E%3A%7E%FA%A5%8F%C5z%AE%BA%A5%BFy%C3%E5%3B%E2-%BD%3B%FDd%C7v%15k%DE%2CU%ED%8B%95%B3%9Eg%8D%12VKl%24%96%BE%D3Z%F6%7E%CBak%E9%8A%D3U%ADM%B5Z%D2%95%E2TT%9E%1E%D2%E5%EC%E1pn%F4P8%7Bt%B0Rxad%DD%F6%83%D53%07%7E%AD/V+K%A6%EFRJ%B9Q%AF%EF%9A%5D-%E9%EE%8B%FB%E3-%7D%9B%FDT%E7%25R%25%B7%08%99%1C@%D4%BF%21%BA%20m%8D%0A%AC%91%9E%D3%60B%ABMhB%5D%0D%8B%A6Z%9D%D2%D5%F2%B8%AE%94N%99j%E9xX%3Aw%2C*%9E%19%AA%CE%BE7R%1C%DF%5B%F0%E2%BD%3A%9A%BB%B0o%88%FF%03%C9%B2%26v%1E%C8%18%09%00%00%00%25tEXtdate%3Acreate%002013-09-14T18%3A41%3A58-03%3A00%E9%21%CE%C1%00%00%00%25tEXtdate%3Amodify%002013-08-31T18%3A29%3A00-03%3A00a%96q@%00%00%00%19tEXtSoftware%00www.inkscape.org%9B%EE%3C%1A%00%00%00%00IEND%AEB%60%82'
  
# End of Constants.


# Auxiliary functions.	

  _extend = (obj_destiny, obj_src) ->
    for key, val of obj_src
      obj_destiny[key] = val
    obj_destiny

  _parsePattern = (pat) ->
    re = /\/:([A-Za-z0-9_]+)+/g
    m = pat.match(re)
    if m
      pars = (x.slice(2) for x in m)
      retpat = pat.replace(re, "/([A-Za-z0-9_\-]+)")
    else
      retpat = pat
      pars = null
    {pattern: retpat, params: pars}
  
  _make_request_wrapper = (cb) ->
    wrapper = (req, res) ->
      body = []
      contentType = 'application/x-www-form-urlencoded'
      if req.headers['content-type']
        contentType = req.headers['content-type']
      mp_index = contentType.indexOf('multipart/form-data')
      if req.method.toLowerCase() isnt 'get'
        req.setEncoding('binary') if (mp_index isnt -1)
        req.on 'data', (chunk) ->
          body.push chunk
        req.on 'end', () ->
          body = body.join ''
          if contentType is 'text/plain'
            body = body.replace('\r\n', '')
          if mp_index is -1
            req.post = _bodyparser(body)
          else
            req.post = _multipartparser(body, contentType)
            for obj in req.post['multipart-data']
              req.fileName = obj.fileName if obj.fileName
              req.fileLen = obj.fileLen if obj.fileLen
              req.fileData = obj.fileData if obj.fileData
              req.fileType = obj.fileType if obj.fileType
          req.body = _extend req.body, req.post
          try
            cb(req, res)
          catch e
            dispatch._500 req, res, req.url, e.toString()
      else
        try
          cb(req, res)
        catch e
          dispatch._500 req, res, req.url, e.toString()

    wrapper

# End of Auxiliary functions.	


# Dispatcher (router) function.	

  dispatch = (req, res) ->
    parsed = urlparse(req.url)
    pathname = parsed.pathname
    pathname = pathname.replace /\/$/, "" if (pathname.split '/') .length > 2
    req.get = if parsed.query? then querystring.parse(parsed.query) else {}
    req.body = _extend {}, req.get
    method = req.method.toLowerCase()
    if dispatch.logging
      dispatch.log "#{req.client.remoteAddress} - [#{new Date().toLocaleString()}] - #{method.toUpperCase()} #{pathname} - HTTP #{req.httpVersion}"

    #selected_method = dispatch.routes[method] or dispatch.routes['any']
    if dispatch.routes[method]
      selected_method = dispatch.routes[method].concat dispatch.routes['any']
    else
      selected_method = dispatch.routes['any']
      
    for route in selected_method
      m = pathname.match(route.pattern)
      if m isnt null
        if route.params
          req.params = {}
          args = m.slice(1)
          for param, index in route.params
            req.params[param] = args[index]
        return route.handler(req, res)

    if pathname is "/"
      for home_page in dispatch.default_home
        full_path = "#{dispatch.static_route}/#{home_page}"
        try
          if fs.existsSync full_path
            return dispatch.static "/#{home_page}", req, res
        catch error
          dispatch.log error.toString() unless not dispatch.logging
      if dispatch.list_dir
        return dispatch.directory dispatch.static_route, '.', res
      else
        return dispatch._404 req, res, pathname

    if dispatch.serve_static
      return dispatch.static pathname, req, res
    else
      return dispatch._404 req, res, pathname

# End of Dispatcher (router) function.	


# Extends default options with client provided ones, and then using that extends dispatcher function itself.	

  _extend(default_options, options)
  _extend(dispatch, default_options)

# End of Extends default options with client provided ones, and then using that extends dispatcher function itself.	


# Directory listing template	

  _dirlist_template = """
      <!DOCTYPE  html>
      <html>
        <head>
            <title>Directory listing for <%= @cwd %></title>
            <style type="text/css" media="screen">

            </style>
        </head>
        <body>
            <h2>Directory listing for <%= @cwd %></h2>
            <hr/>
            <ul id="dircontents">
              <%= @cwd_contents %>
            </ul>
            <hr/>
            <p><strong>Served by #{dispatch.served_by} v#{dispatch.version}</strong></p>
        </body>
      </html>
      """

# End of Directory listing template	


# Dispatch object methods, not meant to be called/used by the client.	

  _pushRoute = (pattern, callback, method) ->
    params = null
    if typeof pattern is "string"
      parsed = _parsePattern(pattern)
      pattern = new RegExp("^#{parsed.pattern}$")
      params = parsed.params
    dispatch.routes[method].push {pattern: pattern, handler: callback, params: params}
    dispatch.routes[method].sort (it1, it2) -> it2.pattern.toString().length > it1.pattern.toString().length


  _multipartparser = (body, content_type) ->
    resp = "multipart-data": []
    boundary = content_type.split(/;\s+/)[1].split('=')[1].trim()
    parts = body.split("--#{boundary}")
    for part in parts
      if part and part.match(/Content-Disposition:/i)
        #dispatch.log "PART: #{part}"
        obj = {}
        m = part.match(/Content-Disposition:\s+(.+?);/i)
        if m
          obj.contentDisposition = m[1]
        m = part.match(/name="(.+?)"/i)
        if m
          obj.fieldName = m[1]
        m = part.match(/filename="(.+?)"/i)
        if m
          obj.fileName = m[1]
        m = part.match(/Content-Type:\s+(.+?)\s/i)
        if m
          obj.fileType = m[1]
        else
          obj.fileType = 'text/plain'
        m = part.match(/Content-Length:\s+(\d+?)/i)
        if m
          obj.contentLength = m[1]

        m = part.match /\r\n\r\n/
        if m
          obj.fileData = part.slice(m.index + 4, -2)
          obj.fileLen = obj.fileData.length
        
        resp['multipart-data'].push obj
    resp

  _bodyparser = (body) ->
    if body.indexOf('=') isnt -1
      try
        return querystring.parse(body)
      catch e
        dispatch.log e unless not dispatch.logging
    try
      return JSON.parse(body)
    catch e
      dispatch.log e unless not dispatch.logging
    body

# End of Dispatch object methods, not meant to be called/used by the client.	


# Dispatch function properties and methods 	

  dispatch.routes =
    get:  []
    post: []
    put:  []
    patch: []
    delete:  []
    any: []

  dispatch.static = (pathname, req, res) ->
    full_path = "#{dispatch.static_route}#{unescape(pathname)}"
    fs.exists full_path, (exists) ->
      if exists
        if ((pathname.indexOf("#{dispatch.cgi_dir}/") isnt - 1) or (pathname.match /\.php$/)) and (pathname.substr(-1) isnt "/") and (dispatch.serve_cgi is true)
          try
            return dispatch.cgi(pathname, req, res)
          catch e
            dispatch.log e.toString() unless not dispatch.logging
            return dispatch._500 null, res, pathname
        else
          fs.stat full_path, (err, stats) ->
            if err
              dispatch.log err.toString() unless not dispatch.logging
              return dispatch._500 null, res, pathname
            if stats
              if stats.isDirectory()
                return dispatch.directory(full_path, pathname, res) unless not dispatch.list_dir
                return dispatch._405(null, res, pathname, "Directory listing not allowed")
              if stats.isFile()
                fd = fs.createReadStream full_path
                res.writeHead 200, {'Content-Type': mime_types[path_tools.extname(full_path)] or 'text/plain'}
                fd.pipe res
      else
        if unescape(pathname).match(/favicon\.ico$/)
          res.writeHead 200, {'Content-Type': mime_types[path_tools.extname('favicon.ico')] or 'application/x-icon'}
          res.end new Buffer(unescape(escaped_icon), 'binary')
        else
          dispatch._404 null, res, pathname

# CGI support (improved on 2012-09-07, further fixes on 2013-08-03)
    
  dispatch.getEnv = (pathname, req, res) ->
    env = {}
    
    #env['REQUEST_HEADERS'] = JSON.stringify(req.headers)
    #env['REQUEST_CONNECTION'] = req.connection.toString()
    
    for key, val of req.headers
      env["HTTP_#{key.toUpperCase().replace('-', '_')}"] = req.headers[key]
    query_pairs = ("#{key}=#{val}" for key, val of req.get)
    if query_pairs.length isnt 0
      env["QUERY_STRING"] = "#{query_pairs.join('&')}"
    else
      env['QUERY_STRING'] = ''
    env['REMOTE_ADDRESS'] = req.connection.remoteAddress
    env['REQUEST_URI'] = pathname
    env['GATEWAY_INTERFACE'] = "CGI/1.1"
    env['SERVER_NAME'] = req.headers.host.split(':')[0]
    env['SERVER_ADDRESS'] = env['SERVER_NAME']
    env['SERVER_SOFTWARE'] = "#{dispatch.software_name}/#{dispatch.version}"
    env['SERVER_PROTOCOL'] = "HTTP/#{req.httpVersion}"
    env['SERVER_PORT'] = req.headers.host.split(':')[1] or 80
    env['REQUEST_METHOD'] = req.method
    env['SCRIPT_NAME'] = pathname
    env['SCRIPT_FILENAME'] = "#{dispatch.static_route}#{unescape(pathname)}"
    
    if dispatch.serve_php
      env['REDIRECT_STATUS'] = '200'
      
    env

  dispatch.cgi = (pathname, req, res) ->
    urlobj = urlparse req.url
    #dispatch.log JSON.stringify urlobj unless not dispatch.logging
    
    respbuffer = ''
    full_path = "#{dispatch.static_route}#{unescape(pathname)}"

    env = dispatch.getEnv pathname, req, res
    
    isPHP =  !!pathname.match(/\.php$/)
    
    prepareChild = (req_body) ->
      if req_body and isPHP
        if not env['QUERY_STRING']
          env['QUERY_STRING'] = ''
        env['QUERY_STRING'] += req_body
        
      if isPHP
        if not dispatch.serve_php
          dispatch._405(null, res, pathname, "PHP scripts not allowed")
          return null
        else
          dispatch.log "Spawning #{dispatch.php_cgi} #{full_path}" unless not dispatch.logging
          child = spawn(dispatch.php_cgi, [full_path], env: env)
      else 
        dispatch.log "Spawning #{full_path}" unless not dispatch.logging
        child = spawn(full_path, [], env: env)

      child.stderr.pipe process.stderr

      child.stdout.on 'data', (data) ->
        arrdata = data.toString().split('\n')
        for elem in arrdata
          if (elem.substr(0,8).toLowerCase() isnt "content-")
            respbuffer += elem
          else
            pair = elem.split(/:\s+/)
            try
              res.setHeader(pair[0], pair[1])
            catch e
              dispatch.log "Error setting response header: #{e.message}" unless not dispatch.logging
      
      child.stdout.on 'end', (moredata) ->
        try
          respbuffer += moredata unless not moredata
          res.end respbuffer
        catch e
          dispatch.log "Error terminating response: #{e.message}" unless not dispatch.logging
    
      return child
      
    body = []
    if req.method.toLowerCase() is "post"
      req.on 'data', (chunk) ->
        body.push(chunk)
      req.on 'end', ->
        body = body.join ''
        req.post = _bodyparser body
        req.body = _extend req.body, req.post
        try
          data = querystring.stringify(req.body)
          #dispatch.log "Data to be posted: #{data}" unless not dispatch.logging
          child = prepareChild(data)
          return if not child 
          d = domain.create()
          d.add child.stdin
          d.on 'error', (err) -> dispatch.log "Child process input error (captured by domain): #{err.message}" unless not dispatch.logging
          d.run(-> child.stdin.write("#{data}\n"); child.stdin.end()) 
        catch e
          dispatch.log "Child process input error: #{e.message}" unless not dispatch.logging
    else
      try
        data = querystring.stringify(req.body)
        dispatch.log "Data to be sent: #{data}" unless not dispatch.logging 
        #child.stdin.write("#{json}\n", "utf8", ((err) -> console.log "ERROR in STDIN" if err)) unless child.stdin._writeableState.ended
        child = prepareChild()
        return if not child
        d = domain.create()
        d.add child.stdin
        d.on 'error', (err) -> dispatch.log "Child process input error (captured by domain): #{err.message}" unless not dispatch.logging
        d.run(-> child.stdin.write("#{data}\n"); child.stdin.end()) 
      catch e
        dispatch.log "Child process input error: #{e.message}" unless not dispatch.logging
    
    0

# End of CGI support

#SCGI Support

  dispatch.sendSCGIRequest = (request, sock) ->
    if request.method.toLowerCase() is 'post'
      encPost = querystring.stringify(request.post)
    else
      encPost = ""
    req = ""
    req += "CONTENT_LENGTH\0#{encPost.length}\0"
    req += "REQUEST_METHOD\0#{request.method}\0"
    req += "REQUEST_URI\0#{request.url}\0"
    req += "QUERY_STRING\0#{querystring.stringify request.get}\0"
    req += "CONTENT_TYPE\0#{request.headers['content-type'] or 'text/plain'}\0"
    req += "DOCUMENT_URI\0#{request.url}\0"
    req += "DOCUMENT_ROOT\0#{'/'}\0"
    req += "SCGI\u0000\u0031\u0000"
    req += "SERVER_PROTOCOL\0HTTP/1.1\0"
    #req += "HTTPS\0#{'$https if_not_empty'}\0"
    req += "REMOTE_ADDR\0#{request.connection.remoteAddress}\0"
    req += "REMOTE_PORT\0#{request.connection.remotePort}\0"
    req += "SERVER_PORT\0#{request.headers['host'].match(/:(\d+)$/)[1] or '80'}\0"
    req += "SERVER_NAME\0#{request.headers['host'].replace /:\d+/, ''}\0"
    for key, val of request.headers
      req += "HTTP_#{key.toUpperCase().replace('-', '_')}\0#{request.headers[key]}\0"
    
    req = "#{req.length}:#{req},#{encPost}"
    dispatch.log "Sending '#{req}' of length #{req.length} to SCGI" if dispatch.logging
    sock.write(req)
    #sock.end()
  
  dispatch.scgi_pass = (conn, request, response) ->
    if not isNaN(parseInt(conn))
      conn_options = port: parseInt(conn)
    else
      conn_options = path: conn
    
    getData = ->
      retval = ""
      client = net.connect(
        #path: '/tmp/hello_scgi_py.sk'
        #port: 26000
        conn_options
        ->
          dispatch.sendSCGIRequest(request, client)
      )
      client.on 'data', (data) ->
        retval += data
      client.on 'end', (data) ->
        retval += data if data
        dispatch.log "Ending SCGI transaction"
        retval = retval.replace /\r/g, ''
        lines = retval.split '\n'
        statusDone = false
        contentTypeDone = false
        headerSet = false
        status = 0
        contentType = ''
        for line, index in lines
          dispatch.log "LINE ##{index + 1}: #{line}"
          if not headerSet
            writeThis = true
            if not statusDone
              m = line.match /Status: (\d+)/i
              if m
                writeThis = false
                statusDone = true
                status = m[1]
                dispatch.log "Detected status: #{status}"
                if contentTypeDone
                  dispatch.log "Response: Status #{status}  - Content-Type: #{contentType}"
                  response.writeHead status, 'Content-Type': contentType or 'text/plain'
                  headerSet = true
            if not contentTypeDone
              m = line.match /Content\-Type\:\s+(.+\/.+)/i
              if m
                writeThis = false
                contentTypeDone = true
                contentType = m[1]
                dispatch.log "Detected Content-Type: #{contentType}"
                if statusDone
                  dispatch.log "Response: Status #{status}  - Content-Type: #{contentType}"
                  response.writeHead status, 'Content-Type': contentType or 'text/plain'
                  headerSet = true
             if writeThis
               response.write line
          else
            response.write line
         
        response.end()
 
    d = domain.create()
    d.on 'error', (e) ->
      response.writeHead 502, 'Bad gateway', 'Content-Type': 'text/plain'
      response.end "502 - Bad gateway\n\n\n#{e.message}"
    d.run getData

# End of SCGI support

  dispatch.proxy_pass = (url, response) ->
    try
      http.get url, (res) ->
        res.pipe response
    catch e
      dispatch._500 null, response, url, e.message

  dispatch.directory = (fpath, path, res) ->
    resp = _dirlist_template
    resp = resp.replace("<%= @cwd %>", path) while resp.indexOf("<%= @cwd %>") isnt -1
    fs.readdir fpath, (err, files) ->
      if err
        return dispatch._404(null, res, path)
      else
        links = ("<li><a href='#{path}/#{querystring.escape(file)}'>#{file}</a></li>" for file in files).join('')
        resp = resp.replace("<%= @cwd_contents %>", links)
      res.writeHead 200, {'Content-type': 'text/html'}
      res.end resp


  dispatch.get = (pattern, callback) ->
      _pushRoute pattern, callback, 'get'

  dispatch.post = (pattern, callback) ->
    _pushRoute pattern, _make_request_wrapper(callback), 'post'

  dispatch.put = (pattern, callback) ->
    _pushRoute pattern, _make_request_wrapper(callback), 'put'
  
  dispatch.patch = (pattern, callback) ->
    _pushRoute pattern, _make_request_wrapper(callback), 'patch'

  dispatch.delete = (pattern, callback) ->
    _pushRoute pattern, callback, 'delete'

  dispatch.del = (pattern, callback) ->
    _pushRoute pattern, callback, 'delete'

  dispatch.any = (pattern, callback) ->
    _pushRoute pattern, _make_request_wrapper(callback), 'any'


  dispatch._404 = (req, res, path) ->
    res.writeHead(404, {'Content-Type': 'text/html'})
    res.end("""
            <h2>404 - Resource #{path} not found at this server</h2>
            <hr/><h3>Served by #{dispatch.served_by} v#{dispatch.version}</h3>
            <p style="text-align: center;"><button onclick='history.back();'>Back</button></p>
        """)

  dispatch._405 = (req, res, path, message) ->
    res.writeHead(405, {'Content-Type': 'text/html'})
    res.end("""
#               <h2>405 - Resource #{path}: #{message}</h2>
                <hr/><h3>Served by #{dispatch.served_by} v#{dispatch.version}</h3>
                <p style="text-align: center;"><button onclick='history.back();'>Back</button></p>
            """)

  dispatch._500 = (req, res, path, message) ->
    res.writeHead(500, {'Content-Type': 'text/html'})
    res.end("""
                <h2>500 - Internal server error at #{path}: #{message}</h2>
                <hr/><h3>Served by #{dispatch.served_by} v#{dispatch.version}</h3>
                <p style="text-align: center;"><button onclick='history.back();'>Back</button></p>
            """)

  dispatch.render_template = (template_string, context, keep_tokens = false) ->
    "Naive regex based implementation of mustache.js spec"

    html_encode = (stri) ->
      String(stri).replace /[<>&'\/"]/g, (m) -> {"<": "&lt;", ">": "&gt;","&": "&amp;","'": "&#39;","/": "&#x2F;","\"": "&quot;"}[m]

    section_pattern = /\{\{(\#|\^)\s*([\w\W]+?)\}\}\n?([\w\W]*?)\n?\{\{\/\s*\2\}\}/
    section_pattern_global = /\{\{(\#|\^)\s*([\w\W]+?)\}\}\n?([\w\W]*?)\n?\{\{\/\s*\2\}\}/g
    variable_pattern = /\{{2}([\w\W]+?)\}{2}/    
    variable_pattern_global = /\{{2}([\w\W]+?)\}{2}/g

    section_tokens = []
    text_tokens = []
    
    stripped_string = template_string
    sections = template_string.match section_pattern_global
    if sections
      for section in sections
        stripped_string = stripped_string.replace(section, '\n@@@\n')
        section_tokens.push(section.match(section_pattern))
      text_tokens = stripped_string.split /\n@@@\n/g
    else
      text_tokens.push template_string
      
    for text_token, index in text_tokens            
      variable_tokens = text_token.match variable_pattern_global
      token_obj = {}
      if variable_tokens
        for token in variable_tokens
          k = token.replace(/\{/g, '').replace(/\}/g, '').trim()
          dont_encode = false
          if k[0] is "&"
            k = k.substring(1).trim()
            dont_encode = true
          token_obj[k] = {token: token, dont_encode: dont_encode}

      new_str = text_token
      for key, value of token_obj
        try
          replacement = eval "context.#{key}"
        catch e
          replacement = null
        if replacement
          new_str = new_str.replace new RegExp(token_obj[key].token, 'g'), if token_obj[key].dont_encode then replacemente else html_encode(replacement)
      #Erase unmatched mustaches
      new_str = new_str.replace variable_pattern_global, '' unless keep_tokens
      text_tokens[index] = new_str

    ret_arr = []
    for text, index in text_tokens
      ret_arr.push text
      if section_tokens[index]
        property = context[section_tokens[index][2].trim()]
        full_text = section_tokens[index][0]
        section_type = if section_tokens[index][1] is "#" then true else false
        section_inner_text = section_tokens[index][3]

        if section_type is false
          ret_arr.push(dispatch.render_template(section_inner_text, context)) if not property
        else
          if property?.length? and (property?.constructor.name isnt "String")
            for item in property
              ret_arr.push(dispatch.render_template(section_inner_text, item))
          else
            ret_arr.push(dispatch.render_template(section_inner_text, context)) if property
    
    ret_arr.join '\n'
    
    
# End of Dispatch function properties and methods 	


# Returns dispatch (router function)	    
  dispatch


# Exports "router factory function"
module.exports = Router
