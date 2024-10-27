questions_list = [{
        "question" : "Fsdfsdfsd",
        "answer" : "fsdfsdfsd"
    },
    {
        "question" : "Fsdfsaaaaadfsd",
        "answer" : "fsdfsdfaaaasd"
    },
    {
        "question" : "",
        "answer" : ""
    }]

for item in questions_list:
    if len(item['question']) == 0 or len(item['answer']) == 0:
        print(False, item)

