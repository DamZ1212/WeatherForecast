# WeatherForecast

Simple app to showed weather forecasts querried on: https://www.infoclimat.fr/api-previsions-meteo.html?id=2988507&cntry=FR

Installation and run:

Project is using a pod (PromiseKit)
Be sure to install the dependecy before running.
Go the project's root directory (where lies the .xcodeproj)
Then:
pod setup
pod init
pod install

Don't forget to open the .xcworkspace file instead of the .xcodeproj one!

When running the app on iphone simulator, location services might give wrong locations that the weather api cannot handle properly.
I suggest to setup a fake location directly on the simulator. Anyway, app works best on real device anyway.

Testing:

The project has a few running unit tests.
UI Tests were not implemented because of a lack of time.
Please run them via dedicated interface in xcode.
