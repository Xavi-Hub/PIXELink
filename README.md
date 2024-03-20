# PIXELink
PIXELink is an iOS app that lets a user search their camera roll by drawing a sketch of the photo they want to find.

### How it works
1. The user draws a rough sketch of the image they want to find (using color blobs)
2. The app breaks down the image into a grid of squares.
3. The app takes the average color of each square in the grid, and compares that to the corresponding square of each image in the camera roll.
4. The app returns the images that have the smallest average color difference for each square.
