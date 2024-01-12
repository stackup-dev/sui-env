module quest_1::postal_service{
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    struct MessageObject has key {
        id: UID,
        secret_number: u8
    }

    public fun create_message_object(secret_number: u8, ctx: &mut TxContext) {
    let messageObject = MessageObject {
        id: object::new(ctx),
        secret_number
    };
    transfer::transfer(messageObject, tx_context::sender(ctx))
    }

    // Can retrieve the message but cannot modify it
    public fun view_message(messageObject: &MessageObject): u8{
        messageObject.secret_number
    }

    // Can view and edit the message but cannot delete it
    public fun update_message(messageObject: &mut MessageObject, new_number: u8){
        messageObject.secret_number = new_number
    }

    // Can do anything with the message, including viewing, editing or deleting
    public fun delete_message(messageObject: MessageObject){
        let MessageObject {id, secret_number: _ } = messageObject;
        object::delete(id);
    }

    struct WrappableMessage has key, store {
        id: UID,
        secret_number: u8,
    }

    struct Envelope has key {
        id: UID,
        message: WrappableMessage,
        intended_address: address
    }

    public fun request_message(message: WrappableMessage, intended_address: address, ctx: &mut TxContext){
        let envelopeObject = Envelope {
            id: object::new(ctx),
            message,
            intended_address
        };
        // Transfer the newly created envelope to the intended address
        transfer::transfer(envelopeObject, intended_address)
    }

    public fun create_wrappable_message_object(_: &MailmanCap, secret_number: u8, ctx: &mut TxContext) {
        let wrappableMessage = WrappableMessage {
            id: object::new(ctx),
            secret_number
        };
        transfer::transfer(wrappableMessage, tx_context::sender(ctx))
    }

    public fun unpack_wrapped_message(envelope: Envelope, ctx: &mut TxContext){
        // Check that the person unpacking the envelope is the intended viewer
        assert!(envelope.intended_address == tx_context::sender(ctx), 0);
        let Envelope {
            id,
            message,
            intended_address:_,
        } = envelope;
        transfer::transfer(message, tx_context::sender(ctx));
        // Delete the wrapper Envelope object
        object::delete(id)
    }

    // Type that marks the capability to create, update, and delete messages
    struct MailmanCap has key {
        id: UID
    }

    // Module initializer is called only once on module publish
    fun init(ctx: &mut TxContext) {
        transfer::transfer(MailmanCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx))
    }
    
}