This is a jsPsych experiment that procedurally generates a Gabor patch based on parameters.

	# psiturk = new PsiTurk uniqueId, adServerLoc, mode


Now we want to create a function that generates Gabor patches. It will do this using the DOM, somehow.



This block describes stimuli.

	test_stimuli = [
		{
			stimulus: "static/images/blue.png"
			data: response: "go"
		}
		{
			stimulus: "static/images/orange.png"
			data: response: "no-go"
		}
	]

Now we repeat the stimuli 10 times and randomize the trial order for stimuli blocks.

	all_trials = jsPsych.randomization.repeat(test_stimuli, 1)

Next, we create a function to set the gap between trials to have a delay of at least 750ms, with some random interval added to it.

	post_trial_gap = ->
		Math.floor(Math.random() * 1500) + 750

Now we define the test block using the above information. Note the `on_finish` function, which evaluates "correctness." Note that whatever is appended using `jsPsych.data.addDataToLastTrial` does not get sent to `on_data_update` in the call to `jsPsych.init` method down below. Instead, we write that data to `psiturk.recordTrialData` *after* we have modified the last trial's information, then send that data to the server.

This kind of "correct" calculation only requires that the data updating and saving methods be called within the block itself when there is calcuation that has to happen to compute "correct" after the fact. This looks worse, but performs better and makes for cleaner data.

	gabor_block =
		type: "single-stim"
		choices: ['F']
		timing_response: 1500
		timing_post_trial: post_trial_gap
		on_finish: (data) ->
			correct = false
			correct = true if data.response == 'go' and data.rt > -1
			correct = true if data.response == 'no-go' and data.rt == -1
			jsPsych.data.addDataToLastTrial({correct: correct})
			# psiturk.recordTrialData(jsPsych.data.getLastTrialData())
			# psiturk.saveData()
			return
		timeline: all_trials

Now we define the experimental timeline using the blocks we created above.

	experiment_blocks = [
		gabor_block
	]

Finally we combine everything to a call to jsPsych to create an experiment. `$('#jspsych-target')` is a jquery call to the named div element in the `exp.html` page.

	jsPsych.init
		display_element: $('#jspsych-target')
		timeline: experiment_blocks
		# show_progress_bar: true
		on_finish: ->
			jsPsych.data.displayData()
		# on_data_update: (data) ->
		# 	console.log(data)
		# 	#psiturk.recordTrialData(data)
		# 	return
