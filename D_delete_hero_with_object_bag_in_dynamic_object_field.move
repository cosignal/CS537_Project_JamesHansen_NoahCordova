module move_gas_optimization::D_delete_hero_with_object_bag_in_dynamic_object_field{
    use sui::dynamic_object_field;
    use sui::object_bag;

    // Set up Hero object structure
    public struct Hero has key, store{
        id: UID
    }

    // Set up individual accessories:
    public struct Sword has key, store{
        id: UID,
        strength: u64
    }

    public struct Shield has key, store{
        id: UID,
        strength: u64
    }

    public struct Hat has key, store{
        id: UID,
        strength: u64
    }

    // Create a single hero, create and add 3 accessories to a bag, add bag to hero as a dynamic field
    public entry fun create_hero_with_obj_bag_in_dynamic_obj_field(ctx: &mut TxContext){
        let mut hero = Hero{id: object::new(ctx)};

        // creating bag
        let mut bag_object = object_bag::new(ctx);
        
        // creating hero attributes
        let mut sword = Sword{id: object::new(ctx), strength: 0};
        let mut shield = Shield{id: object::new(ctx), strength: 0};
        let mut hat = Hat{id: object::new(ctx), strength: 0};
        
        // adding hero attributes to bag
        object_bag::add(&mut bag_object, 0, sword);
        object_bag::add(&mut bag_object, 1, shield);
        object_bag::add(&mut bag_object, 2, hat);

        // adding bag as dynamic object field
        dynamic_object_field::add(&mut hero.id, b"bag", bag_object);
        
        transfer::transfer(hero, tx_context::sender(ctx));
    }

    //Helper Functions: Delete accessories
    public fun delete_sword_from_bag(bag_ref: &mut object_bag::ObjectBag){
        //1) Unpack Sword
        let Sword {id, strength:_} = object_bag::remove(bag_ref, 0);
        //2) Delete ID
        object::delete(id);
    }

    public fun delete_shield_from_bag(bag_ref: &mut object_bag::ObjectBag){
        //1) Unpack Sword
        let Shield {id, strength:_} = object_bag::remove(bag_ref, 1);
        //2) Delete ID
        object::delete(id);
    }

    public fun delete_hat_from_bag(bag_ref: &mut object_bag::ObjectBag){
        //1) Unpack Sword
        let Hat {id, strength:_} = object_bag::remove(bag_ref, 2);
        //2) Delete ID
        object::delete(id);
    }

    // Delete elements within bag
    public fun delete_bag_contents(hero_obj_ref: &mut Hero){
        //1) Set up mut_ref to bag using borrow_mut
        let mut bag_ref: &mut object_bag::ObjectBag = dynamic_object_field::borrow_mut(&mut hero_obj_ref.id, b"bag");
        //2) Call delete on accessories within bag
        delete_sword_from_bag(bag_ref);
        delete_shield_from_bag(bag_ref);
        delete_hat_from_bag(bag_ref);
    }

    // Delete accessories, bag, and hero objects
    public entry fun delete_hero_with_obj_bag_dynamic_obj_fields_detach_and_delete_children(mut hero: Hero){
        //1) Call delete_bag_contents
        delete_bag_contents(&mut hero);
        //2) Unpack and delete Bag
        object_bag::destroy_empty(dynamic_object_field::remove(&mut hero.id, b"bag"));
        //3) Unpack and delete Hero
        let Hero{id} = hero;
        object::delete(id);
    }
}
