# Navet

Navet is a Command line video generator that does not create masterpieces but useful video placeholders.

# How to build `navet`?

You currently need macOS 10.10 or more with Swift 4.0 to build navet

## Build a release binary

- Open a terminal and move to `navet`'s folder and Type: 

```swift build -c release```

- Copy the binary 

```cp .build/x86_64-apple-macosx10.10/release/navet  /usr/local/bin/```

- Verify 

```navet version```

## How to create an xcode project contribute to `navet`

Navet is implemented in swift4.0 and uses swift package manager. 
Go to `navet`'s folder and type:

```shell swift package generate-xcodeproj```

# Parameters


```shell
# navet generate help
Usage: navet generate [options]
  -d, --duration:
      The duration in seconds
  -f, --fps:
      The number of frame per seconds (default 25)
  -p, --video-file-path:
      The video file path. If undefined we will create a navet folder on the desktop
  --color-mode:
      "uniform" "random" or "progressive" (default is "progressive")
  -w, --width:
      The width of the video (default 1080)
  -h, --height:
      The height of the video (default 720)
  --file-type:
      "mov" "m4v" or "mp4" (default is "mov")
  --codec:
      "hevc" "h264" "jpeg"  "proRes4444" or "proRes422" (default is "h264")
```

# Usage Samples

- `navet generate -f 25 -d 10`
- `navet generate -f 60 -d 10 --codec h264 -w 640 -h 480`
- `navet generate -f 30 -d 10 --codec proRes4444 -w 1080 -h 720`

## Result

![sample1](youdub-sample.jpg)

## Progressive colors

![sample1](navet-video-timelapse.gif)

# A shell script to generate a set of 720p references ?

```shell
#!/bin/sh
# 720p
for durationInSeconds in 100
do
	for fps in 24 25 30 60
	do
		for codec in h264 hevc jpeg proRes4444 proRes422
		do
			navet generate -f $fps -d $durationInSeconds --codec $codec -w 1280 -h 720
		done
	done
done
```




# Contact 

[Drop me a message on pereira-da-silva.com](https://pereira-da-silva.com)



