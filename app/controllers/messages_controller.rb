class MessagesController < ApplicationController
 
  # def deliver
  #   Delayed::Job.enqueue(MailingJob.new(params[:id]), 0, 6.minutes.from_now)
  #   flash[:notice] = "Mailing waiting to be delivered."
  #   redirect_to user_path(@user)
  # end


  def index
  	@messages = Message.all
  end

  def show
  	@message = Message.where(id: params[:user_id])
  end

  def new
  	@message = @user.messages.build
  end

  def create
    @user = User.find(session[:user_id])

    @message = @user.messages.create(message_params)
    @message.user_id = current_user.id


      if @message.save
        session[:user_id] = @user.id

        Mailer.delay(run_at: 5.minutes.from_now).spoof_email(@message, @user)


        respond_to do |format|
          format.html {redirect_to user_path(@user), notice: "Message Saved and Sent"}
        end
      else
        #redirect_to @user, notice: "Message Not! Saved"
        render 'users/show'
      end
    

  end

  def edit
    @message = Message.find(params[:id])

    # def time_zone
    #   if message.send_time < Time.now
    #     link_to "edit", edit_user_message_path(current_user, message)
    #   end
    # end


  end

  def update
    @message = Message.find(params[:id])
    if @message.update_attributes(message_params)
      redirect_to user_path(current_user)
    else
      render :edit
    end
  end

  def destroy
    @message = Message.find(params[:id])
    @message.destroy
    redirect_to user_path(current_user)
  end

  protected

  def message_params
    params.require(:message).permit(:user_id, :subject, :recipient, :recipient_email, :recipient_phone_number, :send_time, :text, :created_at, :updated_at)
  end

end
