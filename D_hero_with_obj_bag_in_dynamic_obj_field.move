module move_gas_optimization::D_hero_with_obj_bag_in_dynamic_obj_field{
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

    // Create many hero objects. 
    public entry fun create_heroes_with_obj_bag_in_dynamic_obj_field(ctx: &mut TxContext){
        let mut i = 0;
        while (i < 125){
            // Create Hero object
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

            // adding bag as dynamic object fields
            dynamic_object_field::add(&mut hero.id, b"bag", bag_object);
            transfer::transfer(hero, tx_context::sender(ctx));
            i = i + 1;
        }
    }

    // Repeatedly access hero accessories
    public entry fun access_hero_with_obj_bag_in_dynamic_obj_field(hero_obj_ref: &mut Hero){
        let mut i = 0;
        
        let mut bag_ref: &mut object_bag::ObjectBag = dynamic_object_field::borrow_mut(&mut hero_obj_ref.id, b"bag");
        let mut sword: &mut Sword = object_bag::borrow_mut(bag_ref, 0);
        let mut shield: &mut Shield = object_bag::borrow_mut(bag_ref, 1);
        let mut hat: &mut Hat = object_bag::borrow_mut(bag_ref, 2);
        i = i + 1;

        while (i < 10000){
            bag_ref = dynamic_object_field::borrow_mut(&mut hero_obj_ref.id, b"bag");
            sword = object_bag::borrow_mut(bag_ref, 0);
            shield = object_bag::borrow_mut(bag_ref, 1);
            hat = object_bag::borrow_mut(bag_ref, 2);

            i = i + 1;
        }
    }

    // Repeatedly update hero accessories
    public entry fun update_hero_with_obj_bag_in_dynamic_obj_field(hero_obj_ref: &mut Hero){
        let mut i = 0;
        //First iteration:
        //Get reference to bag within Hero
        let mut bag_ref: &mut object_bag::ObjectBag = dynamic_object_field::borrow_mut(&mut hero_obj_ref.id, b"bag");

        //Get references to elements within bag
        let mut sword: &mut Sword = object_bag::borrow_mut(bag_ref, 0);
        sword.strength = sword.strength + 10;   //note: Must update before getting another mut reference using bag_ref

        let mut shield: &mut Shield = object_bag::borrow_mut(bag_ref, 1);
        shield.strength = shield.strength + 10;

        let mut hat: &mut Hat = object_bag::borrow_mut(bag_ref, 2);
        hat.strength = hat.strength + 10;

        i = i + 1;
        while (i < 10000){
            //Get reference to bag within Hero
            bag_ref = dynamic_object_field::borrow_mut(&mut hero_obj_ref.id, b"bag");

            //Get references to elements within bag
            sword = object_bag::borrow_mut(bag_ref, 0);
            sword.strength = sword.strength + 10;   //note: Must update before getting another mut reference using bag_ref

            shield = object_bag::borrow_mut(bag_ref, 1);
            shield.strength = shield.strength + 10;

            hat = object_bag::borrow_mut(bag_ref, 2);
            hat.strength = hat.strength + 10;

            i = i + 1;
        }
    }
}
