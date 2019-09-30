# System Health

This app monitors the main metrics of your iOS device (CPU, RAM, Battery). 

## Requirements
- Xcode 11 / iOS 13

## What it does
- Monitor CPU, RAM and Battery and display their current state.
- Allows user to define thresholds in the settings. A notification will be posted if the metric goes over this threshold. User can also be notified when it comes back below this threshold. 
- Monitoring and notifications _should_ also occur if the app is in background. 

## Technical notes
- `Context` is the object that holds the different monitors and stores. It is passed between view controllers through their initializers. 
- `Alert` objects are stored in Core Data, which allows a fast fetch of the most recent alerts to display in `DashboardVC`

## Improvements
- Improvements can be done in `Context` to factorize and simplify the observation pattern. `NotificationCenter` implémentation was interesting at first because I needed to observe the status in multiple places but with the current implementation a Delegate pattern would probably be better. 
- `Monitor` objects holds an history of all tracked values. While this is barely used for now, it could be used to draw a graph of the CPU/RAM/Battery usage over time.
- `SettingsStore` uses `UserDefaults` which is fine but it is based on `"cpu"` or `"ram"` variables, which is should be improved with an enum.
- Background monitoring doesn’t seem to work very efficiently. There is a new `BackgroundTask` framework in iOS 13 that may be useful but I did not try it yet. 
- The app use a basic MVC pattern (except the `DashboardHeaderView` which uses a View Model). If this app was meant to be larger, I would have used an MVVM architecture.
