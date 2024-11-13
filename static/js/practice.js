const setId = document.URL.split('/').at(-1); // set id in the URL after the last slash e.g. 12
let currentIndex = 0; // Initialize a variable to keep track of the current question
let answers = [];

function formatDateForSQL(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0'); // Months are 0-indexed
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');
    const milliseconds = String(date.getMilliseconds()).padStart(3, '0'); // Ensure 3 digits

    // Combine into MySQL DATETIME(3) format
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}.${milliseconds}`;
}

function parseSQLDate(sqlDate) {
    // Split the date and time parts
    const [datePart, timePart] = sqlDate.split(' ');
    const [year, month, day] = datePart.split('-');
    const [time, milliseconds] = timePart.split('.');

    // Further split time into hours, minutes, and seconds
    const [hours, minutes, seconds] = time.split(':');

    // Create a new Date object with the parsed components
    // Months are 0-indexed in JavaScript, so we subtract 1 from the month
    return new Date(Date.UTC(
        parseInt(year, 10),
        parseInt(month, 10) - 1, // Month is 0-indexed
        parseInt(day, 10),
        parseInt(hours, 10),
        parseInt(minutes, 10),
        parseInt(seconds, 10),
        milliseconds ? parseInt(milliseconds, 10) : 0 // Milliseconds, default to 0 if not provided
    ));
}

function timeCheckpoint() {
    let now = new Date();
    return formatDateForSQL(now);
}

function showPracticeResults(answers, timeStarted, timeEnded){
    
    // Show time
    totalTime = parseSQLDate(timeEnded) - parseSQLDate(timeStarted); // Calculate how long it took to complete the set 
    const minutes = Math.floor(totalTime / 60000); // 60000 ms in a minute
    const seconds = Math.floor((totalTime % 60000) / 1000); // Remaining seconds
    totalTimeStr = `${minutes}:${seconds.toString().padStart(2, '0')}`;

    // Create html elements
    let divResults = $('<div class="practice-results"></div>')
    divResults.append($('<p>Finished in: ' + totalTimeStr + '</p>'));
    divResults.append($('<p class="practice-score"></p>'))
    tableResults = $('<table class="table-practice-results"><thead><th>Question</th><th>Answer</th><th>Right/Wrong</th><th>Time</th></thead><tbody></tbody></table>');
    divButtons = $('<div class="buttons-practice-results"></div>');
    divButtons.append('<button onclick="window.location.reload()">Practice again</button>');
    if (userLoggedIn){
        divButtons.append('<a href="/my_sets"><button>Back to my sets</button></a>')
    }

    $('.practice-container').append(divResults);
    $('.practice-container').append(tableResults);
    $('.practice-container').append(divButtons);

    score = 0; // How many answers out of how many were correct
    // Go through each answer : question pair
    for(let i = 0; i < answers.length; i ++){
        userAnswer = answers[i].user_answer === 1 ? 'Right' : 'Wrong'; // 1 = Right, 0 = Wrong
        if (userAnswer === 'Right') {
            score++; // correct answers count
        }
        console.log(parseSQLDate(answers[i].time_ended), parseSQLDate(answers[i].time_started));
        let questionTime = parseSQLDate(answers[i].time_ended) - parseSQLDate(answers[i].time_started); // time between each question
        const questionTimeStrMinutes = Math.floor(questionTime / 60000); // 60000 ms in a minute
        const questionTimeStrSeconds = Math.floor((questionTime % 60000) / 1000); // Remaining seconds
        const questionTimeStrMilliseconds = questionTime % 100; // Remaining millisecondsmilliseconds
        console.log(questionTimeStrMilliseconds);
        let questionTimeStr = `${questionTimeStrMinutes}:${questionTimeStrSeconds.toString().padStart(2, '0')}:${questionTimeStrMilliseconds.toString().padStart(2, '0')}`;

        console.log(questionTime);
        let row = $('<tr class="' + userAnswer.toLowerCase() + '-answer-result">' +
            '<td>' + data[i].question + '</td>' + 
            '<td>' + data[i].answer + '</td>' + 
            '<td>' + userAnswer + '</td>' + // right / wrong; what the user responded
            '<td>' + questionTimeStr + '</td>' +
            '<tr>');
        
        tableResults.find('tbody').append(row);
    } // end for

    totalScoreMessage = 'Right answers ' + score + ' / ' + answers.length;
    $('.practice-score').text(totalScoreMessage); // Display how many answers were right

} // end showPracticeResults

function sendPracticeResults(setId, answers, timeStarted, timeEnded){
    requestPayload = {"set_id" : setId, "answers_list" : answers, "time_started" : timeStarted, "time_ended" : timeEnded};
    
    $.ajax({
        url: 'http://localhost:5000/add_practice_session',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(requestPayload),
        success: function(response){
            console.log('Success: ', response);
        },
        error: function(jqXHR, textStatus, errorThrown) {
            console.log('Error:', textStatus, errorThrown);
        }
    });
}

$(document).ready(function() {
    let now = new Date();
    const startTime = formatDateForSQL(now);
    // Create a single practice item to display the question and answer
    const practiceItem = $('<div class="practice-item"></div>');
    const questionDiv = $('<div class="practice-question"></div>');
    const answerDiv = $('<div class="practice-answer" style="display: none;"></div>');
    const toggleButton = $('<button class="practice-item-toggle">Show Answer</button>');
    const buttonContainer = $('<div class="buttons-container-practice"></div>');
    const rightButton = $('<button class="right-answer-button">Right</button>');
    const wrongButton = $('<button class="wrong-answer-button">Wrong</button>');

    // Append elements to the container
    buttonContainer.append(rightButton);
    buttonContainer.append(wrongButton);

    practiceItem.append(questionDiv);
    practiceItem.append(answerDiv);
    practiceItem.append(toggleButton);
    practiceItem.append(buttonContainer);

    $('.practice-container').append(practiceItem);

    // Display the current question
    function displayCurrentQuestion() {
        if (currentIndex < data.length) {
            questionDiv.html('<p>' + data[currentIndex].question + '</p>');
            answerDiv.html('<p>' + data[currentIndex].answer + '</p>');
            
            // Reset visibility and toggle button text for each new question
            answerDiv.hide(); // Hide the answer by default
            questionDiv.show(); // Ensure question is visible
            toggleButton.text('Show Answer'); // Reset button text
        } else {
            // Handle the end of the questions
            let now = new Date();
            //questionDiv.html('<p>No more questions!</p>');
            questionDiv.hide()
            answerDiv.hide();
            toggleButton.hide();
            buttonContainer.hide();

            const stopTime = answers.at(-1).time_ended

            showPracticeResults(answers, startTime, stopTime);
            console.log("answers:", answers);
            console.log(startTime, stopTime); // at(-1) last answer's time
            sendPracticeResults(setId, answers, startTime, stopTime); // make AJAX request to send practice session info
        }
    }

    // Initial display
    displayCurrentQuestion();

    // Toggle answer visibility
    toggleButton.on('click', function() {
        answerDiv.toggle();
        if (toggleButton.text() === 'Show Answer') {
            toggleButton.text('Hide Answer');
        } else {
            toggleButton.text('Show Answer');
        }
    });

    // Right answer button click event
    rightButton.on('click', function() {
        console.log('right');
        let timeStarted = answers.at(-1)?.time_ended ?? startTime; // if the last answer doesn't exist, assign startTime as time started
        answers.push({'item_id' : data[currentIndex].item_id, 'user_answer' : 1, 'time_started' : timeStarted, 'time_ended' : timeCheckpoint()});
        currentIndex++; // Move to the next question
        displayCurrentQuestion(); // Display the next question
    });

    // Wrong answer button click event
    wrongButton.on('click', function() {
        console.log('wrong');
        let timeStarted = answers.at(-1)?.time_ended ?? startTime; // if the last answer doesn't exist, assign startTime as time started
        answers.push({'item_id' : data[currentIndex].item_id, 'user_answer' : 0, 'time_started' : timeStarted, 'time_ended' : timeCheckpoint()});
        currentIndex++; // Move to the next question
        displayCurrentQuestion(); // Display the next question
    });
});