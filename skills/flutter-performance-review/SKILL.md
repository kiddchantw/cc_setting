---
name: flutter-performance-review
description: Use this skill when optimizing Flutter app performance or diagnosing performance issues. Trigger when user asks to optimize performance, fix lag/jank, reduce rebuilds, improve rendering, check memory leaks, profile app performance, or speed up Flutter apps. Examples - "optimize this widget", "why is it lagging?", "reduce rebuilds", "improve performance", "memory leak check", "app is slow", "優化效能", "卡頓", "記憶體洩漏".
---

# Flutter Performance Review & Optimization Guide

Use this comprehensive guide when reviewing Flutter applications for performance issues and optimization opportunities.

## When to Use This Skill

- App is running slowly or laggy
- UI janks during scrolling or animations
- High memory consumption
- Excessive widget rebuilds
- Slow startup time
- Large app bundle size
- Frame rate drops below 60fps
- User requests performance optimization

## Performance Optimization Checklist

### Widget Optimization
- ✅ Use `const` constructors wherever possible to reduce rebuilds
- ✅ Implement proper widget key usage for efficient rebuilds
- ✅ Break large widgets into smaller, reusable components
- ✅ Minimize widget tree depth
- ✅ Use `RepaintBoundary` for complex widgets that don't change often
- ✅ Avoid expensive operations in build methods

### Rebuild Optimization
- ✅ Minimize widget rebuilds with selective listening
- ✅ Use `ValueListenableBuilder` for simple state updates
- ✅ Implement `shouldRebuild` in custom widgets when appropriate
- ✅ Separate stateful and stateless widgets properly
- ✅ Use `AnimatedBuilder` instead of `setState` for animations
- ✅ Avoid using global keys unnecessarily

### List & Scrolling Performance
- ✅ Implement efficient list rendering with `ListView.builder` or `ListView.separated`
- ✅ Use `GridView.builder` for grid layouts
- ✅ Implement lazy loading for long lists
- ✅ Cache list item extent with `itemExtent` or `prototypeItem`
- ✅ Use `AutomaticKeepAliveClientMixin` for preserving list item state
- ✅ Implement pagination for large datasets
- ✅ Avoid expensive calculations in `itemBuilder`

### Image Optimization
- ✅ Optimize image loading with caching and appropriate resolutions
- ✅ Use `CachedNetworkImage` for network images
- ✅ Resize images to appropriate dimensions (avoid large images)
- ✅ Use image compression (WebP format recommended)
- ✅ Implement placeholder and fade-in effects
- ✅ Preload critical images
- ✅ Use `Image.memory` or `Image.asset` efficiently

### Network & Caching
- ✅ Cache network requests appropriately
- ✅ Implement request debouncing and throttling
- ✅ Use HTTP/2 for multiple concurrent requests
- ✅ Compress API responses (gzip)
- ✅ Implement offline-first architecture when appropriate
- ✅ Cache API responses with expiration strategies

### Memory Management
- ✅ Profile memory usage and fix memory leaks
- ✅ Dispose controllers, streams, and listeners properly
- ✅ Avoid memory leaks in StatefulWidgets (dispose method)
- ✅ Use `WeakReference` for circular references
- ✅ Clear image cache when appropriate
- ✅ Monitor memory usage with DevTools

### Computational Performance
- ✅ Use isolates for heavy computational tasks
- ✅ Move expensive operations off the UI thread
- ✅ Use `compute()` function for one-off computations
- ✅ Implement background processing for data parsing
- ✅ Optimize algorithm complexity (Big O)
- ✅ Use memoization for expensive function results

### App Bundle & Startup
- ✅ Minimize app bundle size by removing unused resources
- ✅ Use deferred loading for non-critical features
- ✅ Optimize asset compression
- ✅ Remove unused dependencies
- ✅ Use tree-shaking (automatically done in release builds)
- ✅ Implement splash screen optimization
- ✅ Delay non-critical initializations

### Animation Performance
- ✅ Use `AnimatedBuilder` and `AnimatedWidget` for efficient animations
- ✅ Prefer `Transform` over positional changes
- ✅ Use `Opacity` widget sparingly (expensive)
- ✅ Cache animation values when possible
- ✅ Use `TickerProviderStateMixin` appropriately
- ✅ Avoid animating large widget subtrees

## Profiling & Debugging Tools

### Flutter DevTools
- ✅ Use **Performance overlay** to identify jank
- ✅ Use **Timeline view** to analyze frame rendering
- ✅ Use **Memory view** to detect memory leaks
- ✅ Use **Network profiler** to monitor API calls
- ✅ Use **CPU profiler** to find bottlenecks

### Command-line Tools
```bash
# Performance overlay
flutter run --profile

# Analyze app size
flutter build apk --analyze-size
flutter build ios --analyze-size

# Check for performance issues
flutter analyze
```

### Profiling Widgets
```dart
import 'package:flutter/rendering.dart';

// Enable performance overlay
debugProfileBuildsEnabled = true;
debugProfilePaintsEnabled = true;

// Check rebuild frequency
debugPrintRebuildDirtyWidgets = true;
```

## Common Performance Issues

### 1. Excessive Rebuilds
**Symptoms**: UI feels sluggish, high CPU usage
**Solutions**:
- Use `const` constructors
- Implement proper state management scope
- Use `ValueListenableBuilder` or similar

### 2. N+1 Rendering Problem
**Symptoms**: List scrolling is janky
**Solutions**:
- Use `ListView.builder`
- Implement proper item recycling
- Cache item heights

### 3. Memory Leaks
**Symptoms**: App crashes, memory grows indefinitely
**Solutions**:
- Properly dispose controllers
- Unsubscribe from streams
- Use DevTools memory profiler

### 4. Large Images
**Symptoms**: Slow image loading, high memory
**Solutions**:
- Resize images appropriately
- Use caching strategies
- Compress images

### 5. Synchronous Blocking Operations
**Symptoms**: UI freezes during operations
**Solutions**:
- Use isolates or `compute()`
- Move to background thread
- Implement async/await properly

## Performance Best Practices

1. **Measure First**: Use profiling tools before optimizing
2. **Optimize Hot Paths**: Focus on frequently executed code
3. **Test on Real Devices**: Emulators don't reflect real performance
4. **Profile Release Builds**: Debug builds are slower
5. **Set Performance Targets**: Aim for 60fps (16ms per frame)
6. **Monitor Memory**: Keep memory usage stable
7. **Optimize Incrementally**: Make small, measurable improvements

## Platform-Specific Optimizations

### Android
- Use R8/ProGuard for code shrinking
- Enable multidex if necessary
- Optimize native library loading
- Use Skia rendering engine optimizations

### iOS
- Enable bitcode (if applicable)
- Optimize asset catalogs
- Use Metal for graphics
- Profile with Instruments

## Performance Metrics to Track

- **Frame render time**: < 16ms (60fps)
- **App startup time**: < 3 seconds
- **Memory usage**: Stable, no leaks
- **Bundle size**: As small as possible
- **Network requests**: Cached and optimized
- **Battery usage**: Minimal background activity

## Additional Resources

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools)
- [Performance profiling](https://docs.flutter.dev/perf/ui-performance)
