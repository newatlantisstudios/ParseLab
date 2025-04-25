//
//  SceneDelegate.swift
//  ParseLab
//
//  Created by x on 4/8/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Configure the window scene
        if let windowSceneDelegate = windowScene.delegate as? SceneDelegate {
            let window = UIWindow(windowScene: windowScene)
            
            // Configure window frame to fill the screen (including safe areas)
            window.frame = UIScreen.main.bounds
            
            let viewController = ViewController()
            let navigationController = UINavigationController(rootViewController: viewController)
            
            // Configure navigation bar appearance
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance
            
            window.rootViewController = navigationController
            window.backgroundColor = .systemBackground
            windowSceneDelegate.window = window
            window.makeKeyAndVisible()
        }
        
        // Handle URL opened from Files app (initial launch)
        if let urlContext = connectionOptions.urlContexts.first {
            handle(url: urlContext.url)
        }
    }
    
    // Handle URL opened from Files app or Share Extension (while app is running or in background)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }
        
        // Check if this is a regular file URL or a custom URL scheme
        if urlContext.url.scheme == "parselab" {
            // Handle custom URL scheme from Share Extension
            handleShareExtensionURL(urlContext.url)
        } else {
            // Handle regular file URL
            handle(url: urlContext.url)
        }
    }
    
    private func handleShareExtensionURL(_ url: URL) {
        // Parse the query parameters from the URL
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let urlString = queryItems.first(where: { $0.name == "url" })?.value,
              let fileURL = URL(string: urlString) else {
            print("Error: Invalid URL format from Share Extension")
            return
        }
        
        // Now handle the file URL
        handle(url: fileURL)
    }
    
    private func handle(url: URL) {
        // Ensure it's a file URL
        guard url.isFileURL else {
            print("Error: Received URL is not a file URL.")
            return
        }
        
        // Start accessing the security-scoped resource
        let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        // Pass the URL to the ViewController
        if let navigationController = window?.rootViewController as? UINavigationController,
           let viewController = navigationController.viewControllers.first as? ViewController {
            viewController.handleFileUrl(url)
        } else {
            print("Error: Could not find ViewController to handle the file URL.")
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}
