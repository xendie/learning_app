import traceback

def get_user_practice_sets(connection, user_id):
    cursor = connection.cursor()

    # Get a list of all sets that were made by the user
    query = "SELECT set_id, username, set_name FROM v_sets_per_user WHERE user_id = %s"

    try:
        cursor.execute(query, (user_id,))
        response = []

        for (set_id, username, set_name) in cursor:
            response.append(
                {
                    'set_id' : set_id, 
                    'username' : username,
                    'set_name' : set_name
                }
            )

        return response, 200
    
    except Exception as e:
        print(f"Error: {e}")
        return str(e), 500
        
    finally:
        cursor.close()
        
def get_specific_practice_set(connection, user_id, request_payload):
    cursor = connection.cursor()

    # Be able to access only those sets that were created by the user or are not private
    query = "SELECT * FROM v_set_questions_all_info WHERE id = %s AND (private = 0 OR user_id = %s)" 
    print(query)
    practice_set_id = request_payload['practice_set_id']

    try:
        cursor.execute(query, (practice_set_id, user_id))
        response = []

        for row in cursor:
            print(row)
            response.append(row)
        
        return response, 200

    except Exception as e:
        print(f"Error: {e}")
        return str(e), 500
        
    finally:
        cursor.close()

# insert a set
def insert_practice_set(connection, user_id, request_payload):
    cursor = connection.cursor()
    if "set_name" not in request_payload or "questions_list" not in request_payload:
        return "set_name and questions_list are required fields", 400

    set_name = request_payload["set_name"]  # required
    questions_list = request_payload["questions_list"] # required
    private = request_payload.get("private", 0)  # Defaults to 0 if not provided
    tags_list = request_payload.get("tags", []) # Check if 'tags' is provided, default to an empty list if not

    query_add_set = """ 
        INSERT INTO practice_set(user_id, set_name, private)
        VALUES (%s, %s, %s)
    """

    query_add_item = """
        INSERT INTO practice_set_item(practice_set_id, question, answer)
        VALUES(%s, %s, %s)
    """

    query_add_tags = """
        INSERT INTO practice_set_tags(practice_set_id, tag)
        VALUES (%s, %s);
        """
    
    try:
        cursor.execute(query_add_set, (user_id, set_name, private))
        practice_set_id = cursor.lastrowid
        
        if practice_set_id <= 0: # If the initial insert was successful, otherwise go to except block
            raise Exception("Failed to insert practice set; no valid last row ID")
            
        for item in questions_list:
            cursor.execute(query_add_item, (practice_set_id, item['question'], item['answer'])) 

        for tag in tags_list:
            cursor.execute(query_add_tags, (practice_set_id, tag))

        connection.commit()
        print("Changes commited")
        return f"Set {set_name} created", 201

    except Exception as e:
        print(f"Error: {e}")
        connection.rollback()
        return str(e), 500
    finally:
        cursor.close()

# update a set
def update_practice_set(connection, user_id, request_payload):
    cursor = connection.cursor()
    # update_set_info always gets updated when a tag or item is updated too - CREATE A TRIGGER
    # add_items
    # remove items
    # Do testing: 
    # - pass only one value of each
    # - reqeust without session
    # - pass wrong user id
    # - pass non-existing set_id
    # - pass non-existing item ids
    # - omit item_id
    # - omit question
    # - omit answer


    if 'set_id' not in request_payload:
        raise Exception("Failed to insert practice set item; No set_id provided")

    try:
        params_query_update_set_info = [] # store paramaters to pass to SQL for query_update_set_info
        query_update_set_info = "UPDATE practice_set SET "

        if 'set_name' in request_payload:
            query_update_set_info += 'set_name = %s, '
            params_query_update_set_info.append(request_payload['set_name'])

        if 'private' in request_payload:
            query_update_set_info += 'private = %s, '
            params_query_update_set_info.append(int(request_payload['private']))
        
        query_update_set_info = query_update_set_info.strip(', ' ) + " WHERE id = %s AND user_id = %s" # only author of the set can edit it

        if 'set_id' in request_payload:
            params_query_update_set_info.append(request_payload['set_id'])
        params_query_update_set_info.append(user_id)

        if 'set_name' in request_payload or 'private' in request_payload: # Only execute the query if any of those values were passed
            cursor.execute(query_update_set_info, params_query_update_set_info)
            
        query_get_set_item_ids = "SELECT id FROM practice_set_item WHERE practice_set_id = %s"
        params_get_set_item_ids = [request_payload['set_id']]
        cursor.execute(query_get_set_item_ids, params_get_set_item_ids)
        practice_set_items_ids = []

        for id in cursor: # get a list of all items that belong to this practice set to later check if the request only contained valid ids belonging to this set 
            practice_set_items_ids.append(id[0])

        if 'update_items' in request_payload:
            print("second query starting")
            for item in request_payload['update_items']:
                print('loop start')
                params_query_update_set_items = [] # store paramaters to pass to SQL for query_update_set_items
                query_update_set_items = "UPDATE practice_set_item SET "
                
                if 'question' in item:
                    query_update_set_items += 'question = %s, '
                    params_query_update_set_items.append(item['question'])
                if 'answer' in item:
                    query_update_set_items += 'answer = %s, '
                    params_query_update_set_items.append(item['answer'])
                if 'item_id' in item:
                    params_query_update_set_items.append(item['item_id'])

                query_update_set_items = query_update_set_items.strip(', ') + " WHERE id = %s" # only author of the set can edit it
                if ('question' in item or 'answer' in item) and 'item_id' in item:
                    if int(item['item_id']) in practice_set_items_ids: # if item actually belongs to this set. Preventing from editing items that don't belong to this set.
                        cursor.execute(query_update_set_items, params_query_update_set_items)

        print('committing')
        connection.commit()
        return "Set has been updated", 200
    except Exception as e:
        connection.rollback()
        traceback_info = traceback.format_exc()
        print(f"An error occurred: {str(e)}")
        print(traceback_info)
        return f"Error {str(e)}", 501
    finally:
        cursor.close()
        

     
# delete a set