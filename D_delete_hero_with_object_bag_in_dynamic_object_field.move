module move_gas_optimization::D_delete_hero_with_object_bag_in_dynamic_object_field{
    use sui::dynamic_object_field;
    use sui::object_bag;
    use sui::object;
    use sui::vec;  // Add for vector

    // Existing structs (Hero now has accessories_vector from above file)...

    // Existing helpers (delete_sword_from_bag, etc.)...

    // Delete bag contents (existing)...

    // Delete 1 hero (updated for vector)
    public entry fun delete_hero_with_obj_bag_dynamic_obj_fields_detach_and_delete_children(mut hero: Hero){
        delete_bag_contents(&mut hero);
        object_bag::destroy_empty(dynamic_object_field::remove(&mut hero.id, b"bag"));

        if (option::is_some(&hero.accessories_vector)) {
            let mut accessories_vec = option::extract(&mut hero.accessories_vector);
            let mut k = 0;
            while (k < vec::length(&accessories_vec)) {
                let Accessory { strength: _ } = vec::remove(&mut accessories_vec, 0);
                k = k + 1;
            };
            vec::destroy_empty(accessories_vec);
        };

        let Hero{id, accessories_vector: _} = hero;
        object::delete(id);
    }
}
