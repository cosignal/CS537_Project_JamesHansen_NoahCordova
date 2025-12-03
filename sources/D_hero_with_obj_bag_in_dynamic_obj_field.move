module move_gas_optimization::D_hero_with_obj_bag_in_dynamic_obj_field {
    use sui::dynamic_object_field;
    use sui::object_bag;
    use sui::object::{UID};
    use sui::object;
    use sui::tx_context::{TxContext};
    use sui::tx_context;
    use sui::transfer;

    // ------------------------------
    // Struct definitions
    // ------------------------------

    // Hero with a dynamic object field that points to an ObjectBag
    public struct Hero has key, store {
        id: UID,
    }

    // Individual accessories stored as separate objects in the bag
    public struct Sword has key, store {
        id: UID,
        strength: u64,
    }

    public struct Shield has key, store {
        id: UID,
        strength: u64,
    }

    public struct Hat has key, store {
        id: UID,
        strength: u64,
    }

    // ------------------------------
    // CREATE
    // ------------------------------

    // Create a single Hero with a bag (ObjectBag) of Sword, Shield, Hat
    public entry fun create_hero_with_obj_bag_in_dynamic_obj_field(ctx: &mut TxContext) {
        // Create hero object
        let mut hero = Hero { id: object::new(ctx) };

        // Create bag object
        let mut bag_object = object_bag::new(ctx);

        // Create hero accessories
        let sword  = Sword  { id: object::new(ctx), strength: 0 };
        let shield = Shield { id: object::new(ctx), strength: 0 };
        let hat    = Hat    { id: object::new(ctx), strength: 0 };

        // Add accessories into bag
        object_bag::add(&mut bag_object, 0, sword);
        object_bag::add(&mut bag_object, 1, shield);
        object_bag::add(&mut bag_object, 2, hat);

        // Attach bag as a dynamic object field of Hero
        dynamic_object_field::add(&mut hero.id, b"bag", bag_object);

        // Transfer hero to sender
        transfer::transfer(hero, tx_context::sender(ctx));
    }

    // REQUIRED BY PROJECT:
    // Create 10 Hero objects, each with a bag stored as a DOF
    public entry fun create_heroes_with_obj_bag_in_dynamic_obj_field(ctx: &mut TxContext) {
        let mut i = 0;
        while (i < 10) {
            create_hero_with_obj_bag_in_dynamic_obj_field(ctx);
            i = i + 1;
        }
    }

    // ------------------------------
    // ACCESS (loop of 1000 iterations)
    // ------------------------------

    // Access the Hero's bag and its accessories repeatedly (1000 iterations)
    public entry fun access_hero_with_obj_bag_in_dynamic_obj_field(hero_obj_ref: &mut Hero) {
        let mut i = 0;

        // REQUIRED BY PROJECT: loop 1000 iterations
        while (i < 1000) {
            // Immutable borrow of the bag
            let bag_ref = dynamic_object_field::borrow(&hero_obj_ref.id, b"bag");
            let sword: &Sword  = object_bag::borrow(bag_ref, 0);
            let shield: &Shield = object_bag::borrow(bag_ref, 1);
            let hat: &Hat      = object_bag::borrow(bag_ref, 2);

            // Touch fields so they’re used
            let _ = sword.strength + shield.strength + hat.strength;

            i = i + 1;
        }
    }

    // ------------------------------
    // UPDATE (loop of 1000 iterations)
    // ------------------------------

    // Update the strength values of the accessories 1000 times
    public entry fun update_hero_with_obj_bag_in_dynamic_obj_field(hero_obj_ref: &mut Hero) {
        let mut i = 0;

        // REQUIRED BY PROJECT: loop until 1000 iterations
        while (i < 1000) {
            // Update sword
            {
                let bag_ref = dynamic_object_field::borrow_mut(&mut hero_obj_ref.id, b"bag");
                let sword: &mut Sword = object_bag::borrow_mut(bag_ref, 0);
                sword.strength = sword.strength + 10;
            };

            // Update shield
            {
                let bag_ref = dynamic_object_field::borrow_mut(&mut hero_obj_ref.id, b"bag");
                let shield: &mut Shield = object_bag::borrow_mut(bag_ref, 1);
                shield.strength = shield.strength + 10;
            };

            // Update hat
            {
                let bag_ref = dynamic_object_field::borrow_mut(&mut hero_obj_ref.id, b"bag");
                let hat: &mut Hat = object_bag::borrow_mut(bag_ref, 2);
                hat.strength = hat.strength + 10;
            };

            i = i + 1;
        }
    }

    // ------------------------------
    // DELETE (1 object)
    // ------------------------------

    // Helper: delete Sword from bag
    fun delete_sword_from_bag(bag_ref: &mut object_bag::ObjectBag) {
        let Sword { id, strength: _ } = object_bag::remove(bag_ref, 0);
        object::delete(id);
    }

    // Helper: delete Shield from bag
    fun delete_shield_from_bag(bag_ref: &mut object_bag::ObjectBag) {
        let Shield { id, strength: _ } = object_bag::remove(bag_ref, 1);
        object::delete(id);
    }

    // Helper: delete Hat from bag
    fun delete_hat_from_bag(bag_ref: &mut object_bag::ObjectBag) {
        let Hat { id, strength: _ } = object_bag::remove(bag_ref, 2);
        object::delete(id);
    }

    // Delete the contents of the bag attached to Hero
    fun delete_bag_contents(hero_obj_ref: &mut Hero) {
        let mut bag_ref: &mut object_bag::ObjectBag =
            dynamic_object_field::borrow_mut(&mut hero_obj_ref.id, b"bag");
        delete_sword_from_bag(bag_ref);
        delete_shield_from_bag(bag_ref);
        delete_hat_from_bag(bag_ref);
    }

    // REQUIRED BY PROJECT:
    // Delete ONE Hero: delete bag contents, delete bag, then delete hero
    public entry fun delete_hero_with_obj_bag_dynamic_obj_fields_detach_and_delete_children(
        mut hero: Hero
    ) {
        // 1) Delete contents inside the bag
        delete_bag_contents(&mut hero);

        // 2) Delete the bag object itself
        object_bag::destroy_empty(dynamic_object_field::remove(&mut hero.id, b"bag"));

        // 3) Delete the hero object
        let Hero { id } = hero;
        object::delete(id);
    }
}
