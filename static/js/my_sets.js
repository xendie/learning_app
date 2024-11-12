const dialog = document.querySelector('[delete-dialog]');
const btnCloseDialog = document.querySelector('.close-delete-dialog');
const btnConfirmDelete = document.querySelector('.confirm-delete-dialog')

function setEdit(){
    alert('Edit');
};

function setDelete(element){
    //dialog.show();
    if (confirmAction()){
        let confirmDelete = false;

        let dataId = $(element).closest('tr').attr('data-id');
        let data = {set_id : dataId};

        $.ajax({
            url: siteUrl + '/delete_set',
            method: 'DELETE',
            contentType: 'application/json',
            data: JSON.stringify(data),
            xhrFields: {
                withCredentials: true,
            },
            success: function(response){
                getPracticeSets(); // refresh the sets to reflect that the set was deleted
            },
            error: function(error){
                console.error('Error:', error);
            }
        });
        
    }
};
/*
btnCloseDialog.addEventListener('click', () =>{
    dialog.close();
});

btnConfirmDelete.addEventListener('click', () =>{
    alert('delete');
    dialog.close();

    // get set id
    // ajax request
    // refresh the page
});
*/

function confirmAction() {
    return confirm("Are you sure you want to proceed?"); 
}

function setView(element){
    let dataId = $(element).closest('tr').attr('data-id');
    let data = {practice_set_id : dataId}

    $.ajax({
        url: siteUrl + '/get_full_practice_set',
        method: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(data),
        xhrFields: {
            withCredentials: true,
        },
        success: function(response){
            $(".practice-sets-table").hide();
            $('#pagination-container').hide();
            $('.btn-edit-set').closest('a').attr('href', 'edit_set/' + dataId);
            
            if(response.message) {
                let table = '';
                let setName = response.message[0]['set_name']; 

                $.each(response.message, function(index, practiceItem) {
                    table += '<tr data-id="' + index  + '" userId="' + practiceItem.user_id +'">' +
                            '<td class="index-cell">' + (index + 1) + '</td>' +
                            '<td class="text-to-speech">' + practiceItem.question + '</td>' +
                            '<td class="text-to-speech">' + practiceItem.answer + '</td>'
                            '<td class="options-cell">' +
                                '<button onclick="setDelete()" class="btn-edit">Delete</button>' +
                            '</td>' +
                        '</tr>';
                });
                let newTable = $('<table class="table-practice-set-items"><tbody></tbody></table>'); // Create a new div element for the new table
                $('.display-tables').append(newTable); // 
                $('.table-practice-set-items').find('tbody').html(table); // populate the table with practice questions and answers
                $('.display-tables').find('h1').text(setName); // Display practice set name
                $('.btn-new-set').closest('a').hide(); // Hide New set button
                $('.btn-edit-set').show(); // Show Save button
                $('.btn-back-to-my-sets').show(); // Show back to my sets button
            }

        },
        error: function(error){
            console.error('Error:', error);
        }
    })

    // request specific set info

    // create a new table and display it
    // on row click allow editing
    // Save changes button (greyed out if no changes made)
};

/*
function setPractice(element){
    let dataId = $(element).closest('tr').attr('data-id');
    let data = {set_id : dataId};
    console.log(data);
}; */

// text to speech
/*
function speakText(text) {
    const utterance = new SpeechSynthesisUtterance(text);
    window.speechSynthesis.speak(utterance);
    console.log(window.speechSynthesis.getVoices());
} */

function backToPracticeSets(){
    getPracticeSets();
    $('.btn-new-set').closest('a').show();
    $('.btn-edit-set').hide();
    $('.btn-back-to-my-sets').hide();
    $(".practice-sets-table").show();
    $('#pagination-container').show();
    $('.table-practice-set-items').remove();
}

function paginate(totalItems, itemsPerPage, currentPage) {
    const totalPages = Math.ceil(totalItems / itemsPerPage); // Calculate the total number of pages
    currentPage = Math.max(1, Math.min(currentPage, totalPages)); // Ensure currentPage is within a valid range
    let paginationHTML = '<div class="pagination center-flex">'; 

    // Previous Page Button
    if (currentPage > 1) {
        paginationHTML += `<button class="prev" data-page="${currentPage - 1}">Prev</button>`;
    }

    // Page Numbers (showing a range of pages before and after the current page)
    const range = 3; // Adjust to show more/less pages
    let startPage = Math.max(1, currentPage - range);
    let endPage = Math.min(totalPages, currentPage + range);

    if (startPage === endPage) {
        return
    }

    for (let i = startPage; i <= endPage; i++) {
        if (i === currentPage) {
            paginationHTML += `<button class="active-page">${i}</button>`;  // Highlight active page
        } else {
            paginationHTML += `<button class="page-number" data-page="${i}">${i}</button>`;
        }
    }
    // Next Page Button
    if (currentPage < totalPages) {
        paginationHTML += `<button class="next" data-page="${currentPage + 1}">Next</button>`;
    }
    paginationHTML += '</div>';

    $('#pagination-container').html(paginationHTML); // Pagination controls
    // Handle click events for pagination buttons
    $('.prev, .next, .page-number').on('click', function() {
        let newPage = $(this).data('page');
        paginate(totalItems, itemsPerPage, newPage); // Call paginate with the new page number
        getPracticeSets(newPage);
        // You would also update your item display here, based on the new page number
    });
}

function getPracticeSets(page = '1'){
    $.ajax({
        url: siteUrl + '/get_practice_sets/' + page,
        method: 'GET',
        dataType: 'json',
        xhrFields: {
            withCredentials: true
        },
        success: function(response){
            setsCount = response.row_count;
            
            if (response.message) {
                let table = '';
                $.each(response.message, function(index, practiceSet) {
                    table += '<tr data-id="' + practiceSet.set_id + '" data-name="' + practiceSet.set_name + '" userId="' + practiceSet.username+'">' +
                            '<td class="index-cell">' + (((page - 1) * 20) + index + 1) + '</td>' +
                            '<td>' + practiceSet.set_name + '</td>' +
                            '<td class="options-cell">' +
                                '<button onclick="setView(this)" class="btn-view">View</button>' +
                                '<a href="practice/' + practiceSet.set_id + '"><button onclick="setPractice(this)" class="btn-practice">Practice</button></a>' +
                                '<button onclick="setDelete(this)" class="btn-edit">Delete</button>' +
                            '</td>' +
                        '</tr>';
                });
                $(".practice-sets-table").find('tbody').empty().html(table);
                //$(".practice-sets-table").show();
                if (setsCount === 0){
                    $(".practice-sets-table").hide();
                    noSetsMessage = 'Looks like you have not created any practice sets yet.';
                    $('.display-tables').append('<p>' + noSetsMessage + '</p>');
                } else {
                    $(".practice-sets-table").show();
                }
                paginate(setsCount, 20, page); // totalItems, itemsPerPage, currentPage
            }
        },
        error: function(error) {
            console.error('Error:', error);
        }
    });
}

function showResponseMessages(){
    const responseMessage = sessionStorage.getItem("responseMessage");
    if (responseMessage){
        $('.response-message').text(responseMessage);
        $('.response-message').show();
        sessionStorage.removeItem("responseMessage");
    }
}

$(document).ready(function(){
    
    getPracticeSets();
    showResponseMessages(); // messages a redirection

    // text to speech
    /*
    $(document).on('click', '.text-to-speech', function() {
        speakText($(this).text());
    });
    */
});