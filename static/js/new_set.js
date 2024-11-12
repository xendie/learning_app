$(".new-set-form").on("submit", function(event) { // Prevent the form from submitting the traditional way
        event.preventDefault();
        addNewPracticeSet();
}); // end  $(".new-set-form").on("submit", function(event)

function addNewPracticeSet() { // A function that's called by form submit button (.btn-save-set)
    const rows = $(".new-set-table tbody tr"); // get all rows of the table
    const lastRow = rows.last();
    lastRow.remove();
    // transform form data into a list to be passed to the API end-point
    const data = $(".new-set-form").serializeArray();

    let questions_list = []; // list for questions:answer pairs
    let questions_count = 0; // counter for iterating through all the questions
    let question = ''; // form textarea question
    let answer = ''; // form textarea answer, multiple entries
    let set_name; // form input type text, only one
    let private = 1; // 1 by default, 0 if public is checked

    $(data).each(function(){ // for each questions
        if (this.name == "question") { // probably could have used a switch instead, but it works
            question = this.value;
            questions_count++;
        } else if (this.name == "answer") {
            answer = this.value;
            questions_list[questions_count] = {
                "question" : question,
                "answer" : answer
            }
        } else if (this.name == "set_name") {
            set_name = this.value;
        } else if (this.name == "private") {
            private = this.value;
        }
    }); // end $(data).each(function()
    
    questions_list = questions_list.filter(item => item !== null); // remove the null item from the last row, otherwise the request will be rejected
    requestPayload = {
        "set_name" : set_name,
        "private" : private,
        "questions_list" : questions_list
    }

    // Make an API request to insert the data collected from .new-set-form
    $.ajax({
        url: siteUrl + '/insert_set',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(requestPayload),
        success: function(response) {
            console.log("Success:", response);
            sessionStorage.setItem("responseMessage", response.message); // Store the response to display the response message in the redirected page
            window.location.href = "/my_sets"; // Redirect to my_sets page
        },
        error: function(jqXHR, textStatus, errorThrown) {
            console.error("Error:", textStatus, errorThrown);
        }
    }); // end ajax
} // end addNewPracticeSet

function addNewRow() { // add new row whenever a user enters any value either to question or answer, (called by handleLastRowInput)
    const newRow = $("<tr></tr>");
    const currentRowCount = $(".new-set-table tbody tr").length;
    // Create cells with inputs for question and answer
    const questionCell = $("<td></td>").append(
        $("<textarea>")
            .attr("type", "textarea")
            .attr("name", "question")
            .attr("rowId", currentRowCount)
            .attr("rows", "3")
            .attr("cols", "50")
            .attr("maxlength", 1000)
            .addClass("question-input")
            .addClass("auto-resize-textarea")
            .attr("placeholder", "Enter question")
            .attr("required", true)
            .on("input", adjustTextAreaHeight)
    );

    const answerCell = $("<td></td>").append(
        $("<textarea>")
            .attr("type", "textarea")
            .attr("name", "answer")
            .attr("rowId", currentRowCount)
            .attr("rows", "3")
            .attr("cols", "50")
            .attr("maxlength", 1000)
            .addClass("answer-input")
            .addClass("auto-resize-textarea")
            .attr("placeholder", "Enter answer")
            .attr("required", true)
            .on("input", adjustTextAreaHeight)
    );

    
    newRow.append(questionCell, answerCell); // Append cells to the new row
    
    
    $(".new-set-table tbody").append(newRow); // Append the new row to the table body
    // Add event listeners to check if the user types in the last row
    questionCell.find("textarea").on("input", handleLastRowInput);
    answerCell.find("textarea").on("input", handleLastRowInput);

    newRow.on("focusin", function() { // Add blur event to clean up extra rows when focus is removed
            $(this).data("focused", true);
        });

    newRow.on("focusout", function() {
        const row = $(this);
        // Delay to ensure focusout only triggers after all inputs in the row are unfocused
        setTimeout(function() {
            if (!row.find("textarea:focus").length) {
                row.data("focused", false);
                removeExtraEmptyRows();
            }
        }, 0);
    });
    const rows = $(".new-set-table tbody tr"); // get all rows of the table
    const lastRow = rows.last(); // select last row of the table
    
    if (rows.length > 1){ // Prevent from sending an empty form, but remove the last item because it will always be empty
        lastRow.find("textarea").removeAttr("required");
        //lastRow.remove();
    } 
} // end addNewRow
// Check if the current row is the last one and if it has content, add a new row
function handleLastRowInput() { // call addNewRow() to add a new row whenever a user enters any value either to question or answer
    console.log('event')
    const rows = $(".new-set-table tbody tr");
    const lastRow = rows.last();
    const questionValue = lastRow.find(".question-input").val();
    const answerValue = lastRow.find(".answer-input").val();

    if (questionValue || answerValue) {
        addNewRow(); // Add a new empty row
    }
} // end handleLastRowInput

function removeExtraEmptyRows() { // Automatically remove empty rows when a user removes focus from it, except for the last row for the new data
    const rows = $(".new-set-table tbody tr"); // Get all rows from the table
    let emptyRows = rows.filter(function() { // Check if there are any rows that where question or answer is empty
        const questionValue = $(this).find(".question-input").val();
        const answerValue = $(this).find(".answer-input").val();
        return !questionValue && !answerValue; // Return rows where both fields are empty
    });

    if (emptyRows.length > 1) { // Keep only one empty row as a placeholder to allow the user to insert new data
        emptyRows.not(":last").remove();
    }
} // end removeExtraEmptyRows

function adjustTextAreaHeight() { // Adjust the size of the textareas in the row when there is more data than a cell can fit by default
    const $row = $(this).closest('tr'); // Get the parent row
    const textareas = $row.find('td > textarea'); // Select all textareas in the row

    textareas.css('height', 'auto');
    // Find the maximum scrollHeight
    let maxHeight = 0;
    textareas.each(function() {
        const scrollHeight = this.scrollHeight; // Get the scrollHeight of the current textarea
        if (scrollHeight > maxHeight) {
            maxHeight = scrollHeight; // Update maxHeight if the current one is greater
        }
    });
    textareas.css('height', maxHeight + 'px'); // Set the height of both textareas to the maximum height
} // end adjustTextAreaHeight

$(document).ready(function(){
    // Run this every time the page is loaded
    $('.btn-back-to-my-sets').show(); // Display the back button in this page
    $('.btn-save-set').show(); // Display the Save button in this page
    addNewRow(); // Add the first row to .new-set-form
}); // end $(document).ready(function()