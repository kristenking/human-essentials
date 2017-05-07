class DonationsController < ApplicationController
  # TODO - needs to be able to handle barcodes too
  def track
    @donation = Donation.find(params[:id])
    if (donation_item_params.has_key?(:barcode_id))
      @donation.track_from_barcode(Barcode.find(donation_item_params[:barcode_id]).to_container)
    else
      @donation.track(donation_item_params[:item_id], donation_item_params[:quantity])
    end
  end

  def remove_item
    @donation = Donation.find(params[:id])
    @donation.remove(donation_item_params[:item_id])
  end

  def complete
    @donation = Donation.find(params[:id])
    @donation.complete
    redirect_to donations_path, notice: "Completed!"
  end

  def index
    @completed = Donation.includes(:containers).includes(:inventory).includes(:dropoff_location).completed
    @incomplete = Donation.includes(:containers).includes(:inventory).includes(:dropoff_location).incomplete
  end

  def create
    @donation = Donation.new(donation_params)
    if (@donation.save)
      redirect_to(edit_donation_path(@donation))
    else 
      @inventories = Inventory.all
      @dropoff_locations = DropoffLocation.all
      flash[:notice] = "There was an error starting this donation, try again?"
      render action: :new
    end
  end

  def new
    @inventories = Inventory.all
    @dropoff_locations = DropoffLocation.all
    @donation = Donation.new
  end

  def edit
    @inventories = Inventory.all
    @dropoff_locations = DropoffLocation.all
    @donation = Donation.find(params[:id])
  end

  def show
    @donation = Donation.find(params[:id])
  end

  def update
    @donation = Donation.find(params[:id])
    @donation.update_attributes(donation_params)
    redirect_to(donation_path(@donation))
  end

  def destroy
    Donation.find(params[:id]).destroy
    redirect_to donations_path
  end

private
  def donation_params
    params.require(:donation).permit(:source, :inventory_id, :dropoff_location_id)
  end

  def donation_item_params
    params.require(:donation).permit(:barcode_id, :item_id, :quantity)
  end
end

