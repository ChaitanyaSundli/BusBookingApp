class Route::Index < Trailblazer::Operation
  step :fetch

  def fetch(ctx, current_user:, **)
    ctx[:models] = RoutePolicy::Scope.new(current_user, Route).resolve
                                     .order(created_at: :desc)
  end
end