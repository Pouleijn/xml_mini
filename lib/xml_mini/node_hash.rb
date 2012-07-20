module NodeHash
  CONTENT_ROOT = '__content__'.freeze

  def insert_node_hash_into_parent(hash, name, node_hash)
    case hash[name]
      when Array then
        hash[name] << node_hash
      when Hash then
        hash[name] = [hash[name], node_hash]
      when nil then
        hash[name] = node_hash
    end
  end

  def handle_child_element(child, node_hash)
    if child.element?
      child.to_hash(node_hash)
    elsif child.text? || child.cdata?
      node_hash[CONTENT_ROOT] ||= ''
      node_hash[CONTENT_ROOT] << child.content
    end
  end

  def remove_blank_content_node(node_hash)
    if node_hash.length > 1 && node_hash[CONTENT_ROOT].blank?
      node_hash.delete(CONTENT_ROOT)
    end
  end
end