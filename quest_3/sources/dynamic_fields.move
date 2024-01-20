module quest_3::dynamic_fields_demo{

    // Use modules 
    use sui::dynamic_object_field as ofield;
    use sui::dynamic_field as field;
    
    // Parent struct
    struct Parent has key {
        id: UID,
    }

    // Dynamic field child struct type containing a counter
    struct DFChild has store {
        count: u64
    }

    // Dynamic object field child struct type containing a counter
    struct DOFChild has key, store {
        id: UID,
        count: u64,
    }

    // Adding dynamic fields
        // Adds a DFChild object to the parent object under the name "child"
    public fun add_dfchild(parent: &mut Parent, child: DFChild) {
        field::add(&mut parent.id, name, b"child");
    }

    // Adds a DOFChild object to the parent object under the name "child"
    public fun add_dofchild(parent: &mut Parent, child: DOFChild) {
        ofield::add(&mut parent.id, name, b"child");
    } 

    // Accessing dynamic fields
        // Borrows a reference to a DFChild via its parent object
    public fun borrow_dfchild_via_parent(parent: &Parent, child_name: vector<u8>): &DFChild {
        field::borrow<vector<u8>, DFChild>(&parent.id, child_name)
    }

    // Borrows a reference to a DOFChild via its parent object
    public fun borrow_dofchild_via_parent(parent: &Parent, child_name: vector<u8>): &DOFChild {
        ofield::borrow<vector<u8>, DOFChild>(&parent.id, child_name)
    }

    // Mutating dynamic fields
        // Mutate a DFChild's counter via its parent object
    public fun mutate_dfchild_via_parent(parent: &mut Parent, child_name: vector<u8>) {
        let child = field::borrow_mut<vector<u8>, DFChild>(&mut parent.id, child_name);
        child.count = child.count + 1;
    }

    // Mutate a DOFChild's counter via its parent object
    public fun mutate_dofchild_via_parent(parent: &mut Parent, child_name: vector<u8>) {
        mutate_dofchild(ofield::borrow_mut<vector<u8>, DOFChild>(
            &mut parent.id,
            child_name,
        ));
    }

    // Helper function
    public fun mutate_dofchild(child: &mut DOFChild) {
        child.count = child.count + 1;
    }
    
    // Removing dynamic fields
        // Removes a DFChild given its name and parent object and returns the value
    public fun remove_dfchild(parent: &mut Parent, child_name: vector<u8>): DFChild {
        field::remove<vector<u8>, DFChild>(&mut parent.id, child_name)
    }

    // Deletes a DOFChild given its name and parent object
    public fun delete_dofchild(parent: &mut Parent, child_name: vector<u8>) {
        let DOFChild { id, count: _ } = ofield::remove<vector<u8>, DOFChild>(
            &mut parent.id,
            child_name,
        );
        object::delete(id);
    }

    // Removes a DOFChild from the parent object and transfers it to the caller
    public fun reclaim_dofchild(parent: &mut Parent, child_name: vector<u8>, ctx: &mut TxContext) {
        let child = ofield::remove<vector<u8>, DOFChild>(
            &mut parent.id,
            child_name,
        );
        transfer::transfer(child, tx_context::sender(ctx));
    }
    
}