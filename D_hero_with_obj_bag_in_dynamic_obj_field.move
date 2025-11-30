module move_gas_optimization::D_hero_with_obj_bag_in_dynamic_obj_field{
    use sui::dynamic_object_field;
    use sui::object_bag;
    use sui::object::{self, UID};
    use sui::tx_context::{self, TxContext};
    use sui::transfer;
    use sui::vec;  // Add for vector

    // Existing structs...
    public struct Hero has key, store{
        id: UID,
        accessories_vector: vector<Accessory>?  // Optional: Make optional or add only for large version
    }

    // New Accessory for vector
    public struct Accessory has store {
        strength: u64
    }

    // ... Existing accessory structs (Sword, Shield, Hat)...

    // Create 10 small heroes (no vector)
    public entry fun create_heroes_small(ctx: &mut TxContext){
        let mut i = 0;
        while (i < 10){
            let mut hero = Hero{id: object::new(ctx), accessories_vector: option::none()};  // No vector

            let mut bag_object = object_bag::new(ctx);
            
            let sword = Sword{id: object::new(ctx), strength: 0};
            let shield = Shield{id: object::new(ctx), strength: 0};
            let hat = Hat{id: object::new(ctx), strength: 0};
            
            object_bag::add(&mut bag_object, 0, sword);
            object_bag::add(&mut bag_object, 1, shield);
            object_bag::add(&mut bag_object, 2, hat);

            dynamic_object_field::add(&mut hero.id, b"bag", bag_object);
            transfer::transfer(hero, tx_context::sender(ctx));
            i = i + 1;
        }
    }

    // Create 10 large heroes (with vector)
    public entry fun create_heroes_large(ctx: &mut TxContext){
        let mut i = 0;
        while (i < 10){
            let mut accessories_vec = vec::empty<Accessory>();
            let mut j = 0;
            while (j < 200){  // Or 20 if needed
                vec::push_back(&mut accessories_vec, Accessory{strength: 0});
                j = j + 1;
            }

            let mut hero = Hero{id: object::new(ctx), accessories_vector: option::some(accessories_vec)};

            let mut bag_object = object_bag::new(ctx);
            
            let sword = Sword{id: object::new(ctx), strength: 0};
            let shield = Shield{id: object::new(ctx), strength: 0};
            let hat = Hat{id: object::new(ctx), strength: 0};
            
            object_bag::add(&mut bag_object, 0, sword);
            object_bag::add(&mut bag_object, 1, shield);
            object_bag::add(&mut bag_object, 2, hat);

            dynamic_object_field::add(&mut hero.id, b"bag", bag_object);
            transfer::transfer(hero, tx_context::sender(ctx));
            i = i + 1;
        }
    }

    // Access (1000 iterations, works for both)
    public entry fun access_hero_with_obj_bag_in_dynamic_obj_field(hero_obj_ref: &Hero){
        let mut i = 0;
        
        let bag_ref: &object_bag::ObjectBag = dynamic_object_field::borrow(&hero_obj_ref.id, b"bag");
        let _sword: &Sword = object_bag::borrow(bag_ref, 0);
        let _shield: &Shield = object_bag::borrow(bag_ref, 1);
        let _hat: &Hat = object_bag::borrow(bag_ref, 2);

        while (i < 1000){
            // Borrow again (mutable not needed for access)
            let bag_ref: &object_bag::ObjectBag = dynamic_object_field::borrow(&hero_obj_ref.id, b"bag");
            _sword = object_bag::borrow(bag_ref, 0);
            _shield = object_bag::borrow(bag_ref, 1);
            _hat = object_bag::borrow(bag_ref, 2);
            i = i + 1;
        }
    }

    // Update (1000 iterations, works for both)
    public entry fun update_hero_with_obj_bag_in_dynamic_obj_field(hero_obj_ref: &mut Hero){
        let mut i = 0;
        
        let mut bag_ref: &mut object_bag::ObjectBag = dynamic_object_field::borrow_mut(&mut hero_obj_ref.id, b"bag");
        let mut sword: &mut Sword = object_bag::borrow_mut(bag_ref, 0);
        sword.strength = sword.strength + 10;
        let mut shield: &mut Shield = object_bag::borrow_mut(bag_ref, 1);
        shield.strength = shield.strength + 10;
        let mut hat: &mut Hat = object_bag::borrow_mut(bag_ref, 2);
        hat.strength = hat.strength + 10;

        while (i < 1000){
            bag_ref = dynamic_object_field::borrow_mut(&mut hero_obj_ref.id, b"bag");
            sword = object_bag::borrow_mut(bag_ref, 0);
            sword.strength = sword.strength + 10;
            shield = object_bag::borrow_mut(bag_ref, 1);
            shield.strength = shield.strength + 10;
            hat = object_bag::borrow_mut(bag_ref, 2);
            hat.strength = hat.strength + 10;
            i = i + 1;
        }
    }

    // ... Existing code...
}
