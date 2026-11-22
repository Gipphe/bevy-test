const TILE: f32 = 40.;

#[derive(Component)]
struct GridPos(IVec2);

fn spawn_inventory(mut commands: Commands) {
    let size = UVec2::new(10, 10);
    commands
        .spawn((
            Node {
                width: px(size.x as f32 * TILE),
                height: px(size.y as f32 * TILE),
                align_self: AlignSelf::Center,
                justify_self: JustifySelf::Center,
                ..default()
            },
            Inventory { size, cells: vec![None; (size.x * size.y) as usize] },
        ))
        .with_children(|p| {
            for y in 0..size.y {
                for x in 0..size.x {
                    let c = if (x + y) % 2 == 0 { Color::srgb(0.2, 0.2, 0.8) } else { Color::srgb(0.8, 0.2, 0.2) };
                    p.spawn((
                        Node {
                            position_type: PositionType::Absolute,
                            left: px(x as f32 * TILE),
                            top: px(y as f32 * TILE),
                            width: px(TILE),
                            height: px(TILE),
                            ..default()
                        },
                        BackgroundColor(c),
                    ));
                }
            }
        });
}

fn spawn_item(commands: &mut Commands, inv: Entity, shape: ItemShape, pos: IVec2, color: Color) -> Entity {
    let item = commands
        .spawn((
            Node { position_type: PositionType::Absolute, ..default() },
            GridPos(pos),
            Pickable::IGNORE, // only the cells should pick
        ))
        .with_children(|p| {
            for o in &shape.0 {
                p.spawn((
                    Node {
                        position_type: PositionType::Absolute,
                        left: px(o.x as f32 * TILE),
                        top: px(o.y as f32 * TILE),
                        width: px(TILE),
                        height: px(TILE),
                        border: px(2.).all(),
                        ..default()
                    },
                    BackgroundColor(color),
                    BorderColor::all(color.darker(0.1)),
                    Pickable { should_block_lower: true, is_hoverable: true },
                ));
            }
        })
        .insert(shape)
        .id();
    commands.entity(inv).add_child(item);
    item
}

// Keeps the UI in sync with the data.
fn sync_item_nodes(mut q: Query<(&GridPos, &mut Node), Changed<GridPos>>) {
    for (pos, mut node) in &mut q {
        node.left = px(pos.0.x as f32 * TILE);
        node.top = px(pos.0.y as f32 * TILE);
    }
}

Rotation. When ItemShape changes, despawn and respawn the item's cell children from the new offsets. Add a system with Changed<ItemShape> that calls despawn_children and re-adds them. That's simpler than mutating each cell in place.

Dragging. Attach the observers to the item entity (.observe(...) right after spawn) and use on.event_target(). Pointer events bubble from the cell to the item. Check original_event_target() if you need the specific cell that was hit. Use UiTransform for the drag offset as you do now. On drop, compute cell = ((cursor - inventory_origin) / TILE).floor(), and use that to run can_place.

Drop preview. Spawn a few translucent overlay cells (or tint the existing tiles) for origin + offset for each shape cell, green when can_place returns true and red otherwise. Because Inventory.cells is the source of truth, this is just a loop over the shape.

Your existing hover and outline observers can move onto the item cells. The checkerboard color logic carries over to the background tiles unchanged.

Do you want me to implement this in main.rs and inventory.rs, replacing the current tile-swap drag logic?
