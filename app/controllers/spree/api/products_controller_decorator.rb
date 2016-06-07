Spree::Api::ProductsController.class_eval do
  before_action :load_customer, only: :show

  private

  # Retrieve a customer so we can return stock information specific to that
  # customer
  def load_customer
    user_id = params[:user_id]
    @customer = user_id.present? ? Spree.user_class.find(user_id) : nil
  end
end
