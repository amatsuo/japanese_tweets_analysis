# -*- coding: utf-8 -*-
# downloader
#Import the necessary methods from tweepy library
from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream
#from httplib import IncompleteRead
from requests.packages.urllib3.exceptions import ReadTimeoutError, IncompleteRead

import os
import sys
import time
import requests
import json
import codecs

#Variables that contains the user credentials to access Twitter API


#This is a basic listener that just prints received tweets to stdout.
class StdOutListener(StreamListener):

    def on_data(self, data):
        try:
            with open("/Users/akitaka/Desktop/temp/ja_kr_tweets/tw_json.txt", "a") as myfile:
                myfile.write(data)
            #print(codecs.decode(data, 'unicode-escape', errors = "ignore"))
        except:
            print('cannot write the file')
        return True

    def on_error(self, status):
        print(status)


if __name__ == '__main__':
    cwd = os.getcwd()
    exec(open(cwd + '/tw_credentials/credentials.py').read())
    
    dl_group = "korean"
    credential = CREDENTIALS[0]
    terms = [u"韓国人", u"韓国", u"コリアン"]
    
    #This handles Twitter authetification and the connection to Twitter Streaming API
    l = StdOutListener()
    auth = OAuthHandler(credential["consumer_key"], credential["consumer_secret"])
    auth.set_access_token(credential["access_token"], credential["access_token_secret"])

    while True:
        try:
            stream = Stream(auth, l)
            #This line filter Twitter Streams to capture data by the keywords: 'python', 'javascript', 'ruby'
            stream.filter(track= terms)
        except IncompleteRead:
            print("IncompleteRead")
            requests.post('https://hooks.slack.com/services/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', data = json.dumps({
                'text': u'Error: IncompleteRead'+ str(dl_group)  + u' :sweat_smile:', 
                'username': u'GE2017_bot', 
                'icon_emoji': ":monky_face:", 
                'link_names': 1,
            }))            
            # Oh well, reconnect and keep trucking
            continue
        except AttributeError:
            print("AttributeError")
            requests.post('https://hooks.slack.com/services/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', data = json.dumps({
                'text': u'Error: AttributeError '+ str(dl_group) + u' :sweat_smile:', 
                'username': u'GE2017_bot', 
                'icon_emoji': ":monky_face:", 
                'link_names': 1,
            }))            
            continue
        except KeyboardInterrupt:
            # Or however you want to exit this loop
            stream.disconnect()
            break
        except:
            print("Some Error, sleep 3 senconds")
            requests.post('https://hooks.slack.com/services/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', data = json.dumps({
                'text': u'Error: Some Error '+ str(dl_group) + u' :fearful:', 
                'username': u'GE2017_bot', 
                'icon_emoji': ":monky_face:", 
                'link_names': 1,
            }))            
            time.sleep(3)
            continue
