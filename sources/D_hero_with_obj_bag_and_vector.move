module move_gas_optimization::D_hero_with_obj_bag_and_vector {
    use sui::dynamic_object_field;
    use sui::object_bag;
    use sui::object::{UID};
    use sui::object;
    use sui::tx_context::{TxContext};
    use sui::tx_context;
    use sui::transfer;
    use std::vector;

    // ------------------------------
    // Struct definitions
    // ------------------------------

    // Accessory for the big vector field
    // Needs 'drop' because we drop vector<Accessory> when we delete Hero
    public struct Accessory has copy, drop, store {
        kind: u8,
        strength: u64,
    }

    // Hero with DOF bag AND a big vector of accessories
    public struct Hero has key, store {
        id: UID,
        accessories_vector: vector<Accessory>,
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
    // Helper: build a vector of 200 accessories
    // ------------------------------

    fun make_accessories_vector(): vector<Accessory> {
        let mut v = vector::empty<Accessory>();
        let mut i = 0;
        // REQUIRED BY PROJECT: 200 items
        while (i < 200) {
            let acc = Accessory { kind: 0, strength: 0 };
            vector::push_back(&mut v, acc);
            i = i + 1;
        };
        v
    }

    // ------------------------------
    // CREATE
    // ------------------------------

    // Create a single Hero with both DOF bag and accessories_vector
    public entry fun create_hero_with_obj_bag_and_vector(ctx: &mut TxContext) {
        // Build big vector of 200 accessories
        let accessories_vector = make_accessories_vector();

        // Create hero with vector
        let mut hero = Hero {
            id: object::new(ctx),
            accessories_vector,
        };

        // Create bag object
        let mut bag_object = object_bag::new(ctx);

        // Create hero accessories
        let sword  = Sword  { id: object::new(ctx), strength: 0 };
        let shield = Shield { id: object::new(ctx), strength: 0 };
        let hat    = Hat    { id: object::new(ctx), strength: 0 };

        // Add accessories to bag
        object_bag::add(&mut bag_object, 0, sword);
        object_bag::add(&mut bag_object, 1, shield);
        object_bag::add(&mut bag_object, 2, hat);

        // Attach bag as DOF
        dynamic_object_field::add(&mut hero.id, b"bag", bag_object);

        // Transfer hero to sender
        transfer::transfer(hero, tx_context::sender(ctx));
    }

    // REQUIRED BY PROJECT:
    // Create 10 Heroes with bag + vector
    public entry fun create_heroes_with_obj_bag_and_vector(ctx: &mut TxContext) {
        let mut i = 0;
        while (i < 10) {
            create_hero_with_obj_bag_and_vector(ctx);
            i = i + 1;
        }
    }

    // ------------------------------
    // ACCESS (loop of 1000 iterations)
    // ------------------------------

    // Access DOF bag + first element of accessories_vector, 1000 iterations
    public entry fun access_hero_with_obj_bag_and_vector(hero: &Hero) {
        let mut i = 0;
        // REQUIRED BY PROJECT: 1000 iterations
        while (i < 1000) {
            // Access bag
            let bag_ref = dynamic_object_field::borrow(&hero.id, b"bag");
            let _sword:  &Sword  = object_bag::borrow(bag_ref, 0);
            let _shield: &Shield = object_bag::borrow(bag_ref, 1);
            let _hat:    &Hat    = object_bag::borrow(bag_ref, 2);

            // Access first element of the vector (just to exercise the large object)
            if (vector::length(&hero.accessories_vector) > 0) {
                let acc_ref = vector::borrow(&hero.accessories_vector, 0);
                let _tmp = acc_ref.strength;
            };

            i = i + 1;
        }
    }

    // ------------------------------
    // UPDATE (loop of 1000 iterations)
    // ------------------------------

    // Update DOF bag + first element of accessories_vector, 1000 iterations
    public entry fun update_hero_with_obj_bag_and_vector(hero: &mut Hero) {
        let mut i = 0;
        // REQUIRED BY PROJECT: 1000 iterations
        while (i < 1000) {
            // Update accessories in bag
            let bag_ref = dynamic_object_field::borrow_mut(&mut hero.id, b"bag");

            let sword: &mut Sword = object_bag::borrow_mut(bag_ref, 0);
            sword.strength = sword.strength + 10;

            let shield: &mut Shield = object_bag::borrow_mut(bag_ref, 1);
            shield.strength = shield.strength + 10;

            let hat: &mut Hat = object_bag::borrow_mut(bag_ref, 2);
            hat.strength = hat.strength + 10;

            // Update first element in the vector
            if (vector::length(&hero.accessories_vector) > 0) {
                let acc_ref = vector::borrow_mut(&mut hero.accessories_vector, 0);
                acc_ref.strength = acc_ref.strength + 1;
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

    // Delete elements within bag
    fun delete_bag_contents(hero_obj_ref: &mut Hero) {
        let mut bag_ref: &mut object_bag::ObjectBag =
            dynamic_object_field::borrow_mut(&mut hero_obj_ref.id, b"bag");
        delete_sword_from_bag(bag_ref);
        delete_shield_from_bag(bag_ref);
        delete_hat_from_bag(bag_ref);
    }

    // REQUIRED BY PROJECT:
    // Delete big Hero (with vector) + bag + accessories
    public entry fun delete_hero_with_obj_bag_and_vector_detach_and_delete_children(
        mut hero: Hero
    ) {
        // 1) Delete contents inside the bag
        delete_bag_contents(&mut hero);

        // 2) Delete the bag object
        object_bag::destroy_empty(dynamic_object_field::remove(&mut hero.id, b"bag"));

        // 3) Destructure hero and delete its UID.
        //    accessories_vector: vector<Accessory> now has 'drop' via Accessory.
        let Hero { id, accessories_vector: _ } = hero;
        object::delete(id);
    }
}
