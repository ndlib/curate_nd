module Api
  class CallbackTrxValidator
    attr_reader :trx_id, :user_name_hash, :trx_id_hash

    def initialize(trx_id:, user_name_hash:, trx_id_hash:)
      @trx_id = trx_id
      @user_name_hash = user_name_hash
      @trx_id_hash = trx_id_hash
    end

    def validate
      return false unless trx_id
      return false unless user_name_hash
      return false unless trx_id_hash
      begin
        trx_user = ApiTransaction.find(trx_id).user.username
      rescue ActiveRecord::RecordNotFound
        return false
      end
      return true if (Digest::MD5.hexdigest(trx_id) == trx_id_hash && Digest::MD5.hexdigest(trx_user) == user_name_hash)
      false
    end
  end
end
