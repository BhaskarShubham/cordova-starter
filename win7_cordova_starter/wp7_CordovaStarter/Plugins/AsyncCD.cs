/* daniele.pecora */
using System;
using System.Net;
using System.Text;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using System.Runtime.Serialization;
using Microsoft.Phone.Tasks;
using WP7CordovaClassLib.Cordova;
using WP7CordovaClassLib.Cordova.Commands;
using WP7CordovaClassLib.Cordova.JSON;
/*
 * daniele.pecora
 * Cordova Plugin for asynchronous requests
 * 
 * 
 * */
namespace Cordova.Extension.Commands
{
    public class AsyncCD : BaseCommand
    {
        
        [DataContract]
        public class Options
        {/*maybe i will implement more options, but for now url is enough*/
            [DataMember]
            public string url {get;set;}
        }

        public void getJSON(string options)
        {
            Console.WriteLine("getJSON:"+options);
            String url = "";
            try
            {
                Options opts = WP7CordovaClassLib.Cordova.JSON.JsonHelper.Deserialize<Options[]>(options)[0];
                url=opts.url;
                GetWebResource(url);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR,e.Message);
                this.DispatchCommandResult(pr);
            }
        }

        private void GetWebResource(String url)
        {
            Console.Write("GET "+url);
            HttpWebRequest httpWebRequest = (HttpWebRequest)HttpWebRequest.Create(url);
            httpWebRequest.Method = "GET";
         try{
            httpWebRequest.BeginGetResponse(Response_Completed, httpWebRequest);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
                PluginResult pr = new PluginResult(PluginResult.Status.ERROR);
                this.DispatchCommandResult(pr);
            }
        }

        void Response_Completed(IAsyncResult aResult)
        {
            Console.WriteLine("URL Retrieved");
            PluginResult pr = new PluginResult(PluginResult.Status.ERROR);
            /**
            *
            * The result will be parsed from string to JSON by cordova.<br>
            * So the javascript callback will get a JSON object.
            *
            */
            String result = null;
            try
            {
                result = "";
                //
                HttpWebRequest request = (HttpWebRequest)aResult.AsyncState;
                HttpWebResponse response = (HttpWebResponse)request.EndGetResponse(aResult);

                using (StreamReader streamReader = new StreamReader(response.GetResponseStream()))
                {
                    result = streamReader.ReadToEnd();
                    Console.WriteLine("result:\n"+result);
                }
                if (null == result || "" == result)
                {
                    pr = new PluginResult(PluginResult.Status.NO_RESULT);
                }
                else
                {
                    pr = new PluginResult(PluginResult.Status.OK,result);
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
                pr = new PluginResult(PluginResult.Status.ERROR);
            }
            Console.Write("Success:"+pr.IsSuccess);
            this.DispatchCommandResult(pr);
        } 


    }
}