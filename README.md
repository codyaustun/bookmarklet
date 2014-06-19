In order to improve student engagement, this pull request allows course staff to enable embedded video clips in open end responses, giving students more expressive power. This is the first step towards higher video engagement. Instead of passively watching videos, students must think critically to determine which snippets illustrate their point. This provides students with captivating experiences and clearer responses for the course staff. Consider film or theater classes. With this tool, course staff could ask questions about scenes, movies, or other recordings, and students could reply naturally with precise clips as explanations.

In the future, such rich descriptions would not be limited to questions and prompts. It is our hope that this tool will lead to video annotation so that students can build multimedia notebooks capturing their key take aways. Not only would this be beneficial to students, but it would provide new insights to course staff about what students actually take away from their classes.

To enable the video clipper, the course staff needs to specify a Youtube ID in the settings for the open ended response question. This will generate a snippet button allowing students to select in and out points for their video clips through a modal window.

This addition is done almost entirely in coffeescript with very minimal changes to the combined open ended module python code and html.  The majority of the video clipper is contained in a single coffeescript file, which has two classes: VideoClipper and OmniPlayer. VideoClipper generates html and handles user interactions, while OmniPlayer abstracts away video player specifics for VideoClipper. Currently, Omniplayer only works with YouTube, but additional players, including the edx player, can be added with small additions to OmniPlayer requiring no further changes to the VideoClipper class. 

Some modifications were made to display.coffee for the combined open ended module to set up and remove VideoClipper as needed. To integrate VideoClipper into staff grading, a single call to VideoClipper.generate needed to be made when the problem data was loaded by staff_grading.coffee.

Enabling video response
![open response settings](https://f.cloud.github.com/assets/549702/1100422/f45de1c0-175a-11e3-9b86-fa42ab363d3b.png)

View in Studio
![view in studio](https://f.cloud.github.com/assets/549702/1100424/f4622546-175a-11e3-95c4-66748b4a4d5e.png)

Clip creation
![clip creation](https://f.cloud.github.com/assets/549702/1100419/f4540e52-175a-11e3-83fe-fee3e1193337.png)

Student response
![student response](https://f.cloud.github.com/assets/549702/1100421/f45d6b46-175a-11e3-88fc-9e2f8f8b748d.png)

Staff grading
![staff grading](https://f.cloud.github.com/assets/549702/1100420/f45e6622-175a-11e3-917e-73eceeff78eb.png)

Video cliper viewer
![video clip viewer](https://f.cloud.github.com/assets/549702/1100423/f45fbc52-175a-11e3-95d2-d2f7d23654f7.png)







