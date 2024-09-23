# GPT_scene_relevance_analysis
scene relevance analysis for narratives using GPT-4

The following script uses GPT-4 to analyze the causal relevance between scenes in a narrative, providing a matrix of relevance scores for current scene in relation to previous scenes.

## Overview

The Scene Relevance Analysis tool is designed to:
1. Process narrative scenes sequentially
2. Analyze the causal relevance of each scene to all previous scenes
3. Generate a matrix of relevance scores

## Features

- Provides scores on a scale of 0-10 with 0.5 increments
- Distinguishes between irrelevant, relevant, and pivotal scenes

## How It Works

1. The tool processes scenes **iteratively**
2. For each new scene, it assigns relevance scores to all preceding scenes
3. Scores are presented in a matrix format

## Example

```python
# Example code snippet
matrix = []
scenes = [
    "Scene 1 content...",
    "Scene 2 content...",
    # Add more scenes as needed
]

for i, scene in enumerate(scenes, start=1):
    matrix = analyze_scene(i, scene, matrix)
    print(f"Updated Matrix after Scene {i}:")
    for row in matrix:
        print(row)
    print()
```

Compare2HumanMatrix.m runs permutation test to compare GPT4 matrix and human matrix 

Compare2NeuralMatrix.m calculates correlation between GPT4 matrix and neural reactivation matrices 
