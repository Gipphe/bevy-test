use bevy::prelude::*;

#[derive(Component, Clone)]
struct ItemShape(Vec<IVec2>); // normalized: min x = 0, min y = 0

impl ItemShape {
    fn rotated_cw(&self) -> Self {
        let rot: Vec<IVec2> = self.0.iter().map(|p| IVec2::new(-p.y, p.x)).collect();
        let min = rot.iter().fold(IVec2::MAX, |m, p| m.min(*p));
        Self(rot.into_iter().map(|p| p - min).collect())
    }
}

#[derive(Component)]
struct Inventory {
    size: UVec2,
    cells: Vec<Option<Entity>>,
}

impl Inventory {
    fn is_inside(&self, p: IVec2) -> bool {
        p.x >= 0 && p.y >= 0 && (p.x as u32) < self.size.x && (p.y as u32) < self.size.y
    }

    fn idx(&self, p: IVec2) -> Option<usize> {
        self.is_inside(p)
            .then(|| p.y as usize * self.size.x as usize + p.x as usize)
    }

    fn can_place(&self, shape: &ItemShape, origin: IVec2, ignore: Option<Entity>) -> bool {
        shape.0.iter().all(|o| {
            self.idx(origin + *o)
                .is_some_and(|i| self.cells[i].is_none() || self.cells[i] == ignore)
        })
    }

    fn place(&mut self, item: Entity, shape: &ItemShape, origin: IVec2) {
        for o in &shape.0 {
            let i = self.idx(origin + *o).unwrap();
            self.cells[i] = Some(item);
        }
    }

    fn remove(&mut self, item: Entity) {
        for c in &mut self.cells {
            if *c == Some(item) {
                *c = None;
            }
        }
    }
}

const TILE: f32 = 40.;

#[derive(Component)]
struct GridPos(IVec2);

fn spawn_inventory(mut commands: Commands) {
    let size = UVec2::new(10, 10);
    commands.spawn((
        Node {
            width: px(size.x as f32 * TILE),
            height: px(size.y as f32 * TILE),
            align_self: AlignSelf::Center,
            justify_self: JustifySelf::Center,
            ..Default.default()
        },
        Inventory {
            size,
            cells: vec![None; (size.x * size.y) as usize],
        },
    ));
}
