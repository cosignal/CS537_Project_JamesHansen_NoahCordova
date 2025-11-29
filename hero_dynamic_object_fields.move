module dynamic_vs_wrap::hero_dynamic_object_fields{

    use sui::dynamic_object_field;

    public struct Hero has key, store{
        id: UID
    }

    // sword, shield, hat
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

    public entry fun create_single_hero_dynamic_object_fields(ctx: &mut TxContext){
        let mut hero = Hero{id: object::new(ctx)};

        // creating hero attributes
        let mut sword = Sword{id: object::new(ctx), strength: 0};
        let mut shield = Shield{id: object::new(ctx), strength: 0};
        let mut hat = Hat{id: object::new(ctx), strength: 0};

        // adding attributes to Hero Object
        dynamic_object_field::add(&mut hero.id, b"sword_object_field", sword);
        dynamic_object_field::add(&mut hero.id, b"shield_object_field", shield);
        dynamic_object_field::add(&mut hero.id, b"hat_object_field", hat);

        transfer::transfer(hero, tx_context::sender(ctx));
    }

    public entry fun create_hero_dynamic_object_fields(ctx: &mut TxContext){
        let mut i = 0;
        while(i < 150){
        
            let mut hero = Hero{id: object::new(ctx)};

            let mut sword = Sword{id: object::new(ctx), strength: 0};
            let mut shield = Shield{id: object::new(ctx), strength: 0};
            let mut hat = Hat{id: object::new(ctx), strength: 0};

            dynamic_object_field::add(&mut hero.id, b"sword_object_field", sword);
            dynamic_object_field::add(&mut hero.id, b"shield_object_field", shield);
            dynamic_object_field::add(&mut hero.id, b"hat_object_field", hat);

            transfer::transfer(hero, tx_context::sender(ctx));
            //hero.id.delete();
            //transfer::share_object(hero);
            i = i + 1;
        }

    }

    

    
    //          updating
    public fun mutate_sword(sword: &mut Sword){
        sword.strength = sword.strength + 1;
    }
    public fun  mutate_shield(shield: &mut Shield){
        shield.strength = shield.strength + 1;
    }
    public fun mutate_hat(hat: &mut Hat){ 
        hat.strength = hat.strength + 1;
    }
    //          accessing
    public fun access_sword(sword: &Sword): u64{
        return sword.strength
    }
    public fun access_shield(shield: &Shield): u64{
        return shield.strength
    }
    public fun access_hat(hat: &Hat): u64{
        return hat.strength
    }
    
    public entry fun update_hero_dynamic_object_fields(hero: &mut Hero){
        let mut i = 0;
        while(i < 10000){
            mutate_sword(dynamic_object_field::borrow_mut(&mut hero.id, b"sword_object_field"));
            i = i + 1;
        }
        
    }

    public entry fun update_all_hero_dynamicobject__fields(hero: &mut Hero){
        let mut i = 0;
        while(i < 10000){

            mutate_sword(dynamic_object_field::borrow_mut(&mut hero.id, b"sword_object_field"));
            mutate_shield(dynamic_object_field::borrow_mut(&mut hero.id, b"shield_object_field"));
            mutate_hat(dynamic_object_field::borrow_mut(&mut hero.id, b"hat_object_field"));

            i = i + 1;
        }
        
    }
    // not updating so we use & not &mut
    public entry fun access_hero_dynamic_object_fields(hero: &Hero){
        let mut i = 0;
        let mut test = 0u64;

        while(i < 10000){
            test = access_sword(dynamic_object_field::borrow(&hero.id, b"sword_object_field"));  // not using &mut since we are just reading it
            i = i + 1;
        }
    }

    public entry fun access_all_hero_dynamic_object_fields(hero: &Hero){
        let mut i = 0;
        let mut test = 0u64;

        while(i < 10000){
            test = access_sword(dynamic_object_field::borrow(&hero.id, b"sword_object_field"));
            test = access_shield(dynamic_object_field::borrow(&hero.id, b"shield_object_field"));
            test = access_hat(dynamic_object_field::borrow(&hero.id, b"hat_object_field"));

            i = i + 1;
        }
    }

    public entry fun test_access_hero_dynamic_object_field(hero: &Hero){
        access_sword(dynamic_object_field::borrow(&hero.id, b"sword_object_field"));
    }

    /*
    public entry fun delete_hero_dynamic_object_field(hero: &mut Hero){
        //let hat_id = dynamic_object_field::id(&hero.id, b"hat_object_field");
        //let hat_ref: &Hat = dynamic_object_field::borrow(&hero.id, b"hat_object_field");

        //let Hat{id: id_hat, strength: strength_hat} = 
        let hat: Hat = dynamic_object_field::remove(&mut hero.id, b"hat_object_field");
        object::delete(hat.id);
        //let Hero{id: id1} = hero;
        //object::delete(id1);
        

    }
    */

    // *****************************************************************

    public fun delete_sword(hero: &mut Hero){
        let Sword {id, strength:_} = reclaim_sword(hero);
        object::delete(id);
    }
    public fun delete_shield(hero: &mut Hero){
        let Shield{id, strength:_} = reclaim_shield(hero);
        object::delete(id);
    }
    public fun delete_hat(hero: &mut Hero){
        let Hat{id, strength:_} = reclaim_hat(hero);
        object::delete(id);
    }

    public fun delete_hero(hero: Hero){
        let Hero{id} = hero;
        object::delete(id);
    }


    // reclaiming Dynamic Fields
    public fun reclaim_sword(hero: &mut Hero): Sword{
        dynamic_object_field::remove(&mut hero.id, b"sword_object_field")
    }
    public fun reclaim_shield(hero: &mut Hero): Shield{
        dynamic_object_field::remove(&mut hero.id, b"shield_object_field")
    }
    public fun reclaim_hat(hero: &mut Hero): Hat{
        dynamic_object_field::remove(&mut hero.id, b"hat_object_field")
    }
    
     public entry fun delete_hero_withAccessoriesAttached(hero: Hero){
        let Hero{id: id_hero} = hero;
        object::delete(id_hero);
    }
    
    // ************************************************************************

    public entry fun delete_hero_detachAndDeleteChildren(mut hero: Hero){
        delete_sword(&mut hero);
        delete_shield(&mut hero);
        delete_hat(&mut hero);

        let Hero{id} = hero;
        object::delete(id);
    }
    
    public entry fun delete_hero_detachButNotDeleteChildren(mut hero: Hero, ctx: &mut TxContext){
        let mut test = reclaim_sword(&mut hero);
        transfer::transfer(test, tx_context::sender(ctx));

        let test2 = reclaim_shield(&mut hero);
        transfer::transfer(test2, tx_context::sender(ctx));

        let test3 = reclaim_hat(&mut hero);
        transfer::transfer(test3, tx_context::sender(ctx));
        // transfer to self
        
        let Hero{id} = hero;
        object::delete(id);
        
    }

}
