
# maintain the temperature setting between 0 and 0.4. Lower temperatures produce more consistent and focused outputs, which is crucial for accurate relevance scoring.
# GPT-4 is recommended for this analysis as it demonstrates superior performance in assigning causal relevance scores compared to GPT-3 or GPT-3.5 Turbo.
# The exact output may vary depending on the specific narrative context.

import os
from openai import OpenAI
from dotenv import load_dotenv
from typing import List, Dict

load_dotenv()

# Set up OpenAI API key
openai.api_key = os.getenv("OPENAI_API_KEY")

def get_system_prompt() -> str:
    return '''You are an expert in narrative analysis, specializing in evaluating scene relevance and story coherence. Provide precise causal relevance scores (on a scale of 0-10) for how each preceding scene contributes to the current scene, in the form of a matrix-like structure where each row builds on the previous.'''

def get_user_prompt() -> str:
    return '''You are an expert in narrative analysis, specializing in evaluating causal relevance and story coherence. Your task is to analyze how previous scenes contribute to the understanding of the current scene in an ongoing narrative.

Instructions:
1. For each new scene, assign individual causal relevance scores (on a scale of 0-10) to all preceding scenes
2. Use increments of 0.5 when assigning scores (e.g., 0, 0.5, 1.0, 1.5, ..., 9.5, 10).
3. Present your analysis in a matrix format, where each row represents the current scene, and each column represents a preceding scene.
4. The main diagonal should always be 0, as it represents a scene's contribution to itself.
Only analyze and score scenes that have already been presented.

Scoring Guidelines:  
Irrelevant Scenes (0 - 3): These scenes contain information that is not directly related to the current scene. They may involve different characters, locations, topics, or plotlines, and their removal would not affect the understanding of the current scene. They do not significantly contribute to the progression of the narrative leading to the current moment. 
Examples: A scene where unrelated side characters have a conversation or an event occurs in a completely different setting. 
Ensure variation: Use at least three distinct scores (e.g., 0, 1.5, 2.5) depending on how far removed the scene is from the current one in terms of relevance. Scenes that are more disconnected should have lower scores. 
Relevant Scenes (3.5 - 7): These scenes provide important background information, thematic connections, or context that enhances the understanding of the current scene. They often involve similar characters, locations, or ongoing subplots, but are not essential for fully grasping the current scene's meaning. The narrative can still be understood without them, though the scene's richness might be reduced. Key difference from Irrelevant: Relevant scenes often share similar elements (characters, setting, themes) with the current scene, but their contribution is more about adding depth, not being critical. 
Examples: A conversation between characters that provides background context or character motivations, but doesn't directly drive the plot of the current scene. 
Ensure variation: Use at least four distinct scores (e.g., 3.5, 5, 6, 7) depending on how much context the past scene contributes to the current one. Scenes that offer more direct thematic or emotional connection should have higher scores. 
Pivotal Scenes (7.5 - 10): These scenes are essential for understanding the current scene. If a pivotal scene is removed, the current scene would lose critical context and become incomprehensible. Pivotal scenes directly set up major events, decisions, or turning points that are integral to the ongoing narrative. Key difference from Relevant: Pivotal scenes must be directly tied to the current scene's plot. Removing them would render the current scene unclear or incomplete. 
Examples: A key revelation, a major character decision, or a critical event that directly influences the current scene. 
Ensure variation: Use at least three distinct scores (e.g., 7.5, 8.5, 9.5) based on how critical the scene is. The more essential the scene is for understanding the current one, the higher the score. 

Additional Requirements:   
Do not assign the same score repeatedly within a category unless the contribution of two scenes is explicitly equal. Every score should reflect the varying levels of contribution from past scenes.   
Provide diversity in scoring by ensuring that each analyzed scene gets a distinct score based on its unique level of contribution.  
Example: If Scene 2 provides background context and Scene 3 contains a direct setup for the major event in the current scene, their contributions should be rated differently (e.g., Scene 2: 4.5, Scene 3: 7.5). Avoid assigning the same score repeatedly within a category.  
I will provide each scene iteratively.'''

def generate_matrix(scenes: List[str]) -> List[List[float]]:
    matrix = []
    
    for i, scene in enumerate(scenes):
        messages = [
            {"role": "system", "content": get_system_prompt()},
            {"role": "user", "content": get_user_prompt()},
        ]
        
        # Add previous scenes and their analyses
        for j in range(i):
            messages.append({"role": "user", "content": f"Scene {j+1}: {scenes[j]}"})
            if j > 0:
                messages.append({"role": "assistant", "content": f"Matrix for Scene {j+1}: {matrix[j-1]}"})
        
        # Add current scene
        messages.append({"role": "user", "content": f"Scene {i+1}: {scene}"})
        
        # Make API call
        response = openai.ChatCompletion.create(
            model="gpt-4-0613",
            messages=messages,
            temperature=0.4,
            max_tokens=2048,
            top_p=1,
            frequency_penalty=0,
            presence_penalty=0
        )
        
        # Extract matrix from response
        matrix_text = response.choices[0].message.content
        matrix_row = [float(score) for score in matrix_text.split("|")[2:-1]]
        matrix.append(matrix_row)
    
    return matrix

def print_matrix(matrix: List[List[float]]):
    for i, row in enumerate(matrix):
        print(f"Scene {i+1}: {row}")

if __name__ == "__main__":
    # Example usage
    scenes = [
        "Scene 1 description",
        "Scene 2 description",
        "Scene 3 description",
        "Scene 4 description",
        # Add more scenes as needed
    ]
    
    matrix = generate_matrix(scenes)
    print_matrix(matrix)
