"""
Address route handlers.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User, Address
from app.schemas import AddressResponse, AddressCreate, AddressUpdate
from app.utils.auth import get_current_user

router = APIRouter()


@router.get("")
async def get_addresses(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get user's addresses."""
    addresses = db.query(Address).filter(
        Address.user_id == current_user.id).all()
    return [
        {
            "id": addr.id,
            "user_id": addr.user_id,
            "name": addr.name,
            "phone": addr.phone,
            "building_number": addr.building_number,
            "address": addr.address,
            "landmark": addr.landmark,
            "city": addr.city,
            "state": addr.state,
            "pincode": addr.pincode,
            "alternate_phone": addr.alternate_phone,
            "is_default": addr.is_default,
            "created_at": addr.created_at.isoformat() if addr.created_at else None,
        }
        for addr in addresses
    ]


@router.post("")
async def add_address(
    request: AddressCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Add new address."""
    # If this is the first address or marked as default, unset other defaults
    if request.is_default:
        db.query(Address).filter(
            Address.user_id == current_user.id,
        ).update({"is_default": False})

    # Check if this is the first address
    existing_count = db.query(Address).filter(
        Address.user_id == current_user.id,
    ).count()

    address = Address(
        user_id=current_user.id,
        name=request.name,
        phone=request.phone,
        building_number=request.building_number,
        address=request.address,
        landmark=request.landmark,
        city=request.city,
        state=request.state,
        pincode=request.pincode,
        alternate_phone=request.alternate_phone,
        is_default=request.is_default or existing_count == 0,
    )
    db.add(address)
    db.commit()
    db.refresh(address)

    return {
        "id": address.id,
        "user_id": address.user_id,
        "name": address.name,
        "phone": address.phone,
        "building_number": address.building_number,
        "address": address.address,
        "landmark": address.landmark,
        "city": address.city,
        "state": address.state,
        "pincode": address.pincode,
        "alternate_phone": address.alternate_phone,
        "is_default": address.is_default,
        "created_at": address.created_at.isoformat() if address.created_at else None,
    }


@router.put("/{address_id}")
async def update_address(
    address_id: int,
    request: AddressUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update address."""
    address = db.query(Address).filter(
        Address.id == address_id,
        Address.user_id == current_user.id,
    ).first()

    if not address:
        raise HTTPException(status_code=404, detail="Address not found")

    # Update fields
    if request.name is not None:
        address.name = request.name
    if request.phone is not None:
        address.phone = request.phone
    if request.building_number is not None:
        address.building_number = request.building_number
    if request.address is not None:
        address.address = request.address
    if request.landmark is not None:
        address.landmark = request.landmark
    if request.city is not None:
        address.city = request.city
    if request.state is not None:
        address.state = request.state
    if request.pincode is not None:
        address.pincode = request.pincode
    if request.alternate_phone is not None:
        address.alternate_phone = request.alternate_phone

    if request.is_default:
        # Unset other defaults
        db.query(Address).filter(
            Address.user_id == current_user.id,
            Address.id != address_id,
        ).update({"is_default": False})
        address.is_default = True

    db.commit()
    db.refresh(address)

    return {
        "id": address.id,
        "user_id": address.user_id,
        "name": address.name,
        "phone": address.phone,
        "building_number": address.building_number,
        "address": address.address,
        "landmark": address.landmark,
        "city": address.city,
        "state": address.state,
        "pincode": address.pincode,
        "alternate_phone": address.alternate_phone,
        "is_default": address.is_default,
        "created_at": address.created_at.isoformat() if address.created_at else None,
    }


@router.delete("/{address_id}")
async def delete_address(
    address_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Delete address."""
    address = db.query(Address).filter(
        Address.id == address_id,
        Address.user_id == current_user.id,
    ).first()

    if not address:
        raise HTTPException(status_code=404, detail="Address not found")

    db.delete(address)
    db.commit()

    return {"success": True, "message": "Address deleted"}


@router.post("/{address_id}/set-default")
async def set_default_address(
    address_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Set address as default."""
    address = db.query(Address).filter(
        Address.id == address_id,
        Address.user_id == current_user.id,
    ).first()

    if not address:
        raise HTTPException(status_code=404, detail="Address not found")

    # Unset all defaults
    db.query(Address).filter(
        Address.user_id == current_user.id,
    ).update({"is_default": False})

    # Set this as default
    address.is_default = True
    db.commit()

    return {"success": True, "message": "Default address updated"}
