/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License. 
*/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using Microsoft.Phone.Controls;
using System.IO;
using System.Windows.Media.Imaging;
using System.Windows.Resources;
using Microsoft.Phone.Shell;
using wp7_CordovaStarter.res.values;
using res.values;

namespace wp7_CordovaStarter
{
    public partial class MainPage : PhoneApplicationPage
    {
        //position of the menuitem and button in applicationbar
        private int pos_refresh_stop_button_item=1;
        // Constructor
        public MainPage()
        {
            InitializeComponent();
            initApplicationBar();
            this.CordovaView.Loaded += CordovaView_Loaded;
        }
        private void initApplicationBar(){
        //TODO 
        //replace the static text setup in xaml file from all buttons and menuitems with localizable values of ValuesResources
        //...
            String[] strings_items = new String[] { 
            ValuesResource.app_menu_item_home,
            ValuesResource.app_menu_item_refresh,
            ValuesResource.app_menu_item_menu,
            ValuesResource.app_menut_item_quit
            };
            for (int i = 0; i < ApplicationBar.MenuItems.Count; i++)
            {
              ApplicationBarMenuItem mi= ApplicationBar.MenuItems[i] as ApplicationBarMenuItem;
                mi.Text=strings_items[i];
            }
            String[] strings_buttons = new String[] { 
            ValuesResource.app_menu_button_home,
            ValuesResource.app_menu_button_refresh,
            ValuesResource.app_menu_button_menu
            };
            for (int i = 0; i < ApplicationBar.Buttons.Count; i++)
            {
                ApplicationBarIconButton b = ApplicationBar.Buttons[i] as ApplicationBarIconButton;
                b.Text = strings_buttons[i];
            }
        }
        private void CordovaView_Loaded(object sender, RoutedEventArgs e)
        {
            this.CordovaView.Loaded -= CordovaView_Loaded;
            // first time load will have an animation
            Storyboard _storyBoard = new Storyboard();
            DoubleAnimation animation = new DoubleAnimation()
            {
                From = 0,
                Duration = TimeSpan.FromSeconds(0.6),
                To = 90
            };
            Storyboard.SetTarget(animation, SplashProjector);
            Storyboard.SetTargetProperty(animation, new PropertyPath("RotationY"));
            _storyBoard.Children.Add(animation);
            _storyBoard.Begin();
            _storyBoard.Completed += Splash_Completed;
            //add eventhandler to get the page loading status
            this.CordovaView.Browser.Navigating += Browser_Navigating;
            this.CordovaView.Browser.Navigated += Browser_Navigated;
            this.CordovaView.Browser.NavigationFailed += Browser_NavigationFailed;
        }

        void Splash_Completed(object sender, EventArgs e)
        {
            (sender as Storyboard).Completed -= Splash_Completed;
            LayoutRoot.Children.Remove(SplashImage);


            BuildApplicationBar();
        }

        // Helper function to build a localized ApplicationBar
        private void BuildApplicationBar()
        {
            // Set the page's ApplicationBar to a new instance of ApplicationBar.
            //ApplicationBar = new ApplicationBar();

            // Create a new button and set the text value to the localized string from AppResources.
            //ApplicationBarIconButton appBarButton = new ApplicationBarIconButton(new Uri("ApplicationIcon.png", UriKind.Relative));
            //appBarButton.Text = AppResources.ButtonText;
            //ApplicationBar.Buttons.Add(appBarButton);

            // Create a new menu item with the localized string from AppResources.
            //ApplicationBarMenuItem appBarMenuItem_refresh = new ApplicationBarMenuItem(ValuesResource.app_menu_button_refresh);
            //ApplicationBar.MenuItems.Add(appBarMenuItem_refresh);

            //foreach(ApplicationBarMenuItem item in ApplicationBar.MenuItems){
            //    item.Click += new EventHandler(ApplicationBarMenuItem_Click);
            //}
            
            //add dynamically new menu item
            /*
            ApplicationBarMenuItem appBarMenuItem_item = new ApplicationBarMenuItem(ValuesResource.app_menu_button_refresh+" (dyn)");
            ApplicationBar.MenuItems.Add(appBarMenuItem_item);
            */
        }
        private void ApplicationBarMenuItem_Click_home(object sender, EventArgs e)
        {
            System.Uri uri = new System.Uri(ValuesResource.start_page);
            this.CordovaView.Browser.Navigate(uri);
            /*
            byte[] postdata = new byte[] { };
            String additionalHeaders = "";
            this.CordovaView.Browser.Navigate(uri, postdata, additionalHeaders);
             * */
        }
        /**
         * Navigatr to the startpage that contains a list of all services available
         */
        private void ApplicationBarMenuItem_Click_menu(object sender, EventArgs e)
        {
            System.Uri uri = new System.Uri(ValuesResource.app_olav_startpage);
            this.CordovaView.Browser.Navigate(uri);
            /*
            byte[] postdata = new byte[] { };
            String additionalHeaders = "";
            this.CordovaView.Browser.Navigate(uri, postdata, additionalHeaders);
             * */
        }
        /**
         * refresh current location in browser control
         */
        private void ApplicationBarMenuItem_Click_refresh(object sender, EventArgs e)
        {
            String currentURL = "";
            Boolean isAbsolute = this.CordovaView.Browser.Source.IsAbsoluteUri;
            if (isAbsolute)
            {
               currentURL= this.CordovaView.Browser.Source.AbsoluteUri;
            }else{
                currentURL ="x-wmapp1:"+ this.CordovaView.Browser.Source.OriginalString; 
            }
            
            Console.WriteLine("currentURL:"+currentURL);
            System.Uri uri = new System.Uri(currentURL);
            this.CordovaView.Browser.Navigate(uri);
            /*
            byte[] postdata = new byte[] { };
            String additionalHeaders = "";
            this.CordovaView.Browser.Navigate(uri, postdata, additionalHeaders);
             * */
        }
        private void ApplicationBarMenuItem_Click_stop(object sender, EventArgs e)
        {
            this.CordovaView.Browser.InvokeScript("eval", "document.execCommand('Stop');");
            //reset the applicationbar button to status 'refresh'
            this.toggleApplicationBarRefreshAndStopAndMenuItemsContent(true);
        }
        /**
         * just an empty eventhandler that is used for the initial status of the disabled refresh button in applicationbar.
         * this is ruled by the xaml tag attribute 'Click'
         * in further workflow i'll use the right handlers 'stop' and 'refresh'
         */
        private void ApplicationBarMenuItem_Click_refreshOrStop(object sender, EventArgs e)
        {
        //just an empty eventhandler that is used for the initial status of the disabled refresh button in applicationbar.
        //in further workflow i'll use the right handlers 'stop' and 'refresh'
        }
        private void ApplicationBarMenuItem_Click_quit(object sender, EventArgs e)
        {
            Application.Current.UnhandledException += exitEventHandler;
            App.Current.UnhandledException += exitEventHandler;

            /*
             * I'm forced to throw an execption to close the app, because the WP7 Api does not offer any function to close app!
             */
            throw new Exception("ExitAppException");

        }
        //react on current page loading status
        //e.g.: toggle a button or applicationbar item between 'refresh' and 'stop'
        /**
         * Navigation Begin
         * 
         */
        private void Browser_Navigating(object sender, Microsoft.Phone.Controls.NavigatingEventArgs e)
        {
            Console.WriteLine("Browser_Navigating:" + sender);
            toggleApplicationBarRefreshAndStopAndMenuItemsContent(false);
        }
        /**
         * Navigation End
         * 
         */
        private void Browser_Navigated(object sender, System.Windows.Navigation.NavigationEventArgs e)
        {
            Console.WriteLine("Browser_Navigated:" + sender);
            toggleApplicationBarRefreshAndStopAndMenuItemsContent(true);
        }
        /**
         * Navigation Failed
         * 
         */
        private void Browser_NavigationFailed(object sender, System.Windows.Navigation.NavigationFailedEventArgs e)
        {
            Console.WriteLine("Browser_NavigationFailed:" + sender);
            toggleApplicationBarRefreshAndStopAndMenuItemsContent(true);
        }
        /**
         * Toggles betweeen the buttons and menuitems 'Refresh' and 'Stop' depending on page loaded or page loading status.<br>
         * We just change the content of one button, if we change the button itself, the applicationbar disappear and reappears every change we make.<br>
         * this causes a bad user experience because the applicationbar makes your eyes go crazy...
         */
        private void toggleApplicationBarRefreshAndStopAndMenuItemsContent(Boolean navigationEnded)
        {
            if (navigationEnded)
            {
                ApplicationBarIconButton b = ApplicationBar.Buttons[pos_refresh_stop_button_item] as ApplicationBarIconButton;
                b.Text = ValuesResource.app_menu_button_refresh;
                b.IconUri = new Uri("icons/appbar.refresh.rest.png",UriKind.Relative);
                b.Click -= ApplicationBarMenuItem_Click_stop;
                b.Click += ApplicationBarMenuItem_Click_refresh;
                b.IsEnabled = true;

                ApplicationBarMenuItem m = ApplicationBar.MenuItems[pos_refresh_stop_button_item] as ApplicationBarMenuItem;
                m.Text = ValuesResource.app_menu_item_refresh;
                m.Click -= ApplicationBarMenuItem_Click_stop;
                m.Click += ApplicationBarMenuItem_Click_refresh;
                m.IsEnabled = true;
            }
            else
            {
                ApplicationBarIconButton b = ApplicationBar.Buttons[pos_refresh_stop_button_item] as ApplicationBarIconButton;
                b.Text = ValuesResource.app_menu_item_stop;
                b.IconUri = new Uri("icons/appbar.stop.rest.png", UriKind.Relative);
                b.Click -= ApplicationBarMenuItem_Click_refresh;
                b.Click += ApplicationBarMenuItem_Click_stop;
                b.IsEnabled = true;

                ApplicationBarMenuItem m = ApplicationBar.MenuItems[pos_refresh_stop_button_item] as ApplicationBarMenuItem;
                m.Text = ValuesResource.app_menu_item_stop;
                m.Click -= ApplicationBarMenuItem_Click_refresh;
                m.Click += ApplicationBarMenuItem_Click_stop;
                m.IsEnabled = true;
            }
        }
        /**
         * UnhadledExceptionHandler (ExitHandler) 
         */
        private void exitEventHandler (object arg0, ApplicationUnhandledExceptionEventArgs arg1){
            Console.WriteLine("-------------------");
            Console.WriteLine(arg0);
            Console.WriteLine(arg1.ExceptionObject.Message);
            Console.WriteLine("-------------------");
            return ;
        }

    }
}
