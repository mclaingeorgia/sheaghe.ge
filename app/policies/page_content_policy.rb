class PageContentPolicy < ApplicationPolicy

  def index?
    user.admin?
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin?
  end

end
