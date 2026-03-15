"""
Seed script to populate categories in the database.
Run with: python -m app.seed_categories
"""

from app.database import SessionLocal, engine, Base
from app.models import Category

# Create tables if they don't exist
Base.metadata.create_all(bind=engine)


def seed_categories():
    """Seed the categories table with initial data."""
    db = SessionLocal()
    
    try:
        # Check if categories already exist
        existing = db.query(Category).count()
        if existing > 0:
            print(f"Categories already exist ({existing} found). Skipping seed.")
            return
        
        # Main categories
        main_categories = [
            {"name": "Hair Band", "sort_order": 1},
            {"name": "Hair Pins", "sort_order": 2},
            {"name": "Saree Pins", "sort_order": 3},
            {"name": "Clips", "sort_order": 4},
            {"name": "Necklace", "sort_order": 5},
            {"name": "Bracelet", "sort_order": 6},
            {"name": "Rings", "sort_order": 7},
            {"name": "Watches", "sort_order": 8},
            {"name": "Fancy Mirror", "sort_order": 9},
            {"name": "Earrings", "sort_order": 10},
        ]
        
        # Earrings subcategories
        earring_subcategories = [
            {"name": "Crystal Earrings", "sort_order": 1},
            {"name": "Long Earrings", "sort_order": 2},
            {"name": "Short Earrings", "sort_order": 3},
            {"name": "Round Earrings", "sort_order": 4},
            {"name": "Rose Gold Earrings", "sort_order": 5},
            {"name": "Silver Plated Earrings", "sort_order": 6},
            {"name": "Gold Plated Earrings", "sort_order": 7},
        ]
        
        # Insert main categories
        earrings_category = None
        for cat_data in main_categories:
            category = Category(
                name=cat_data["name"],
                sort_order=cat_data["sort_order"],
                is_active=True,
            )
            db.add(category)
            db.flush()  # Get the ID
            
            if cat_data["name"] == "Earrings":
                earrings_category = category
        
        # Insert earrings subcategories
        if earrings_category:
            for sub_data in earring_subcategories:
                subcategory = Category(
                    name=sub_data["name"],
                    parent_id=earrings_category.id,
                    sort_order=sub_data["sort_order"],
                    is_active=True,
                )
                db.add(subcategory)
        
        db.commit()
        print("Categories seeded successfully!")
        print(f"Created {len(main_categories)} main categories")
        print(f"Created {len(earring_subcategories)} subcategories under Earrings")
        
    except Exception as e:
        db.rollback()
        print(f"Error seeding categories: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    seed_categories()
