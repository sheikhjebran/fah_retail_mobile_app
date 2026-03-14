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
            "full_name": addr.full_name,
            "phone": addr.phone,
            "address_line1": addr.address_line1,
            "address_line2": addr.address_line2,
            "city": addr.city,
            "state": addr.state,
            "pincode": addr.pincode,
            "label": addr.label,
            "is_default": addr.is_default,
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
        full_name=request.full_name,
        phone=request.phone,
        address_line1=request.address_line1,
        address_line2=request.address_line2,
        city=request.city,
        state=request.state,
        pincode=request.pincode,
        label=request.label,
        is_default=request.is_default or existing_count == 0,
    )
    db.add(address)
    db.commit()
    db.refresh(address)

    return {
        "id": address.id,
        "full_name": address.full_name,
        "phone": address.phone,
        "address_line1": address.address_line1,
        "address_line2": address.address_line2,
        "city": address.city,
        "state": address.state,
        "pincode": address.pincode,
        "label": address.label,
        "is_default": address.is_default,
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
    if request.full_name:
        address.full_name = request.full_name
    if request.phone:
        address.phone = request.phone
    if request.address_line1:
        address.address_line1 = request.address_line1
    if request.address_line2 is not None:
        address.address_line2 = request.address_line2
    if request.city:
        address.city = request.city
    if request.state:
        address.state = request.state
    if request.pincode:
        address.pincode = request.pincode
    if request.label:
        address.label = request.label

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
        "full_name": address.full_name,
        "phone": address.phone,
        "address_line1": address.address_line1,
        "address_line2": address.address_line2,
        "city": address.city,
        "state": address.state,
        "pincode": address.pincode,
        "label": address.label,
        "is_default": address.is_default,
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
