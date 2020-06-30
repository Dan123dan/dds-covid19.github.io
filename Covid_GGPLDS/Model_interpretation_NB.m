function Model_interpretation_NB(m_ikj,r,theta,psi,K_prime,X_orig_avg1,S0,S,K,W,Z,D,T,rr,dataset_name,X_recon)

    data_type = dataset_name;
    method = 'overlap'
    m_iks_new =sum(m_ikj,3);
    m_skj_new =squeeze(sum(m_ikj,1));
    m_iss_new = sum(m_iks_new,1);
    [~ , rdex] = sort(m_iss_new,'descend');
    m_iks_new = m_iks_new(:,rdex);
    m_skj_new = m_skj_new(rdex,:);
    r_new = r(rdex);
    theta_new = theta(:,rdex);
    psi_new = psi(rdex,:);
    [mvalues_theta,mdex_theta]=max(m_iks_new,[],2);
    [mvalues_psi,mdex_psi]=max(m_skj_new,[],1);
    mvalues_theta_copy = mvalues_theta;
    mvalues_psi_copy = mvalues_psi;
    mdex_theta_copy = mdex_theta;
    mdex_psi_copy = mdex_psi;
    l=0;
    for tempind = K_prime:-1:1

        if max(mdex_theta_copy(mvalues_theta_copy>0))==size(m_iks_new,2)-l
            mdex_theta_copy = mdex_theta_copy(mdex_theta_copy<size(m_iks_new,2)-l);
            mvalues_theta_copy = mvalues_theta_copy(mdex_theta_copy<size(m_iks_new,2)-l);
        else
            emptycommunity = size(m_iks_new,2)-l;
            mdex_theta(mvalues_theta==0)= emptycommunity ;
            break
        end
        l =l+1;
    end
    l=0;
    for tempind = K_prime:-1:1

        if max(mdex_psi_copy(mvalues_psi_copy>0))==size(m_skj_new,1)-l
            mdex_psi_copy = mdex_psi_copy(mdex_psi_copy<size(m_skj_new,1)-l);
            mvalues_psi_copy = mvalues_psi_copy(mdex_psi_copy<size(m_skj_new,1)-l);
        else
            emptycommunity = size(m_skj_new,1)-l;
            mdex_psi(mvalues_psi==0)= emptycommunity ;
            break
        end
        l =l+1;

    end
    community_dex = unique(intersect(mdex_theta,mdex_psi));  
    row_sort_index=[];
    col_sort_index=[];
    for jj= 1:length(community_dex)
        comdex_theta=find(mdex_theta==community_dex(jj));
        [~,tempdex]=sort(mvalues_theta(comdex_theta),'descend');
        row_sort_index= cat(1,row_sort_index,comdex_theta(tempdex));
        community_length_row(jj) = size(comdex_theta,1);

        comdex_psi=find(mdex_psi==community_dex(jj));
        [~,tempdex]=sort(mvalues_psi(comdex_psi),'descend');
        col_sort_index= cat(2,col_sort_index,comdex_psi(tempdex));
        community_length_col(jj) = size(comdex_psi,2);
    end


    theta_new2=theta_new(row_sort_index,:);
    psi_new2=psi_new(:,col_sort_index);
    %zetta_new = zetta(row_sort_index);
    %figure;imagesc(theta_new2*diag(r_new)*theta_new2')
    lambda_ij_new=theta_new2*diag(r_new)*psi_new2;
    p_ij = 1-exp(-lambda_ij_new);
    figure;
    for k =1:K_prime
        %subplot(2,3,k)
        subplot(4,4,k)
        community_new_k(:,:,k)=theta_new2(:,k)*r_new(k)*psi_new2(k,:);
        imagesc(community_new_k(:,:,k)./(lambda_ij_new+1e-1))
        title(['Community ',num2str(k)],'FontSize', 9)
        caxis([0 1]);
    end
    hp4 = get(subplot(4,4,16),'Position')

    colorbar('Position', [hp4(1)+hp4(3)+0.01  hp4(2)  0.015  hp4(2)+hp4(3)*4.1])
   % colorbar('Position', [hp4(1)+hp4(3)+0.02  hp4(2)  0.015  hp4(2)+hp4(3)*3.2])
    suptitle('Formed overlapping Communities in Symmetric Model')
    fig1=gcf;
    fig1.Renderer='Painters';

    fig = gcf;
    fig.PaperPositionMode = 'auto'
    fig_pos = fig.PaperPosition;
    fig.PaperSize = [fig_pos(3) fig_pos(4)];
    
    
   

    W_new= W(row_sort_index,:);
    W_new= W_new(:,col_sort_index);
    Z_new = Z(row_sort_index,:);
    Z_new = Z_new(:,col_sort_index);
    S0_new = S0(col_sort_index);
    S_new = S(col_sort_index,:);
    S_new_r =  S(row_sort_index,:);
    D_new = D(:,row_sort_index);
    for k = 1:6
        St_community_new(:,:,k) = ((W_new.*Z_new).*(community_new_k(:,:,k)./(lambda_ij_new+1e-8))) * [S0_new S_new(:,1:T-1)];
    end
    SS = ((W_new.*Z_new)* [S0_new S_new(:,1:T-1)]);
    SS2 = [S0_new S_new(:,1:T-1)];
     figure
         for k =1:5 %K_prime
            %subplot(4,4,k)
            if k==1
                subplot(2,3,[1,2])
                imagesc(Z_new)
                title('Z ','FontWeight','bold','FontSize', 16)
                caxis([0 1]);
            elseif k==2
                subplot(2,3,k+1)
                imagesc(p_ij)
                title(['$1-e^{-\sum_{\kappa}r_{\kappa} \theta_{i\kappa} \psi_{\kappa j}} $'],'interpreter','latex','FontSize', 18)
                %title(['1-exp({-\Sigma_{\kappa}r_{\kappa}\theta_{i\kappa}\psi_{\kappa j}})' ],'FontSize', 12)
                caxis([0 1]);
            elseif k==3
                subplot(2,3,k+1)
                imagesc(theta_new2)
                title('\Theta','FontWeight','bold','FontSize', 16)
                %caxis([0 1]);
             elseif k==4
                subplot(2,3,k+1)
                imagesc(diag(r_new))
                title('R','FontWeight','bold','FontSize', 16)
                %caxis([0 1]);
              elseif k==5
                 subplot(2,3,k+1)
                imagesc(psi_new2)
                title('\Psi','FontWeight','bold','FontSize', 16)
                %caxis([0 1]);
             end

        end
        hp4 = get(subplot(2,3,6),'Position')

        %colorbar('Position', [hp4(1)+hp4(3)+0.01  hp4(2)  0.015  hp4(2)+hp4(3)*4.1])
        %colorbar('Position', [hp4(1)+hp4(3)+0.02  hp4(2)  0.015  hp4(2)+hp4(3)*3.2])
        suptitle('Transition Binary Matrix and construction componenets')
        fig1=figure(1);
        fig1.Renderer='Painters';

        fig = gcf;
        fig.PaperPositionMode = 'auto'
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];

    %figure;plot3(St_community_new(1,:,1),St_community_new(21,:,2),St_community_new(24,:,3))
    if strcmp(data_type,'Covid19_newcases')
         
        if strcmp(method,'overlap')

            figure;plot3(St_community_new(1,:,1),St_community_new(1+community_length_row(1),:,2),St_community_new(1+community_length_row(1)+community_length_row(2),:,3))
            for cc = 1:4
                    temptemp(:,:,cc)=(D_new* St_community_new(:,:,cc));        
            end


            figure
          for i =1:6
                for cc = 1:4
                    subplot(6,5,5*(i-1)+cc)
                    plot((temptemp(i,:,cc)))
                    xlim([0 100])
                    if i==1
                        title(['Community ',num2str(cc)],'FontSize', 9)
                    end
                    if cc==1
                        ylabel(['d',num2str(i)],'FontSize', 9)
                        hYLabel = get(gca,'YLabel');
                        set(hYLabel,'rotation',0,'VerticalAlignment','middle')
                       % title(['d',num2str(i)],'FontSize', 9,'position',[-200 0])
                    end

                end
                hhhh= sum(temptemp,3);
                subplot(6,5,5*(i-1)+cc+1)
                plot(rr.*exp(hhhh(i,:)))
                hold on
               % plot(X_recon_avg1(i,:))
               % hold on
                plot(X_orig_avg1(i,:))
                xlim([0 100])
            % plot(X_recon_avg1(i,:))
            end

        suptitle('Data reconstruction from each community on each dimension')
        fig1=figure;
        fig1.Renderer='Painters';

        fig = gcf;
        fig.PaperPositionMode = 'auto'
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];
        figure
          for j =1:6
                i = j+6;
                for cc = 1:4

                    subplot(6,5,5*(j-1)+cc)
                    plot((temptemp(i+j,:,cc)))
                    xlim([0 100])
                    if j==1
                        title(['Community ',num2str(cc)],'FontSize', 9)
                    end
                    if cc==1
                        ylabel(['d',num2str(i)],'FontSize', 9)
                        hYLabel = get(gca,'YLabel');
                        set(hYLabel,'rotation',0,'VerticalAlignment','middle')
                       % title(['d',num2str(i)],'FontSize', 9,'position',[-200 0])
                    end

                end
                hhhh= sum(temptemp,3);
                subplot(6,5,5*(j-1)+cc+1)
                plot(rr.*exp(hhhh(i,:)))
                hold on
    %             plot(X_recon_avg1(i,:))
    %             hold on
                plot(X_orig_avg1(i,:))
                xlim([0 100])
            % plot(X_recon_avg1(i,:))
            end

        suptitle('Data reconstruction from each community on each dimension')
        fig1=figure;
        fig1.Renderer='Painters';

        fig = gcf;
        fig.PaperPositionMode = 'auto'
        fig_pos = fig.PaperPosition;
        fig.PaperSize = [fig_pos(3) fig_pos(4)];


        elseif strcmp(method,'nonoverlap')

            st_tracker_row = 0;
            st_tracker_col = 0;
            for k =1:K_prime
                temp = zeros(K,K);
                if k< length(community_dex)-1
                    if k==1
                        temp(1:community_length_row(k),1:community_length_col(k)) = community_new_k(1:community_length_row(k),1:community_length_col(k),k);
                        community_new_k1(:,:,k)=temp;
                        st_tracker_row = st_tracker_row + community_length_row(k);
                        st_tracker_col = st_tracker_col + community_length_col(k);
                    else
                        temp( st_tracker_row+1: st_tracker_row+community_length_row(k), st_tracker_col+1: st_tracker_col+community_length_col(k)) = community_new_k( st_tracker_row+1: st_tracker_row+community_length_row(k), st_tracker_col+1: st_tracker_col+community_length_col(k),k);
                        community_new_k1(:,:,k)=temp;
                        st_tracker_row = st_tracker_row + community_length_row(k);
                        st_tracker_col = st_tracker_col + community_length_col(k);
                    end
                else
                     community_new_k1(:,:,k)=temp;
                end
                subplot(4,4,k)
                if  k== 1
                    imagesc(community_new_k1(:,:,1)./(lambda_ij_new+1e-1));
                else
                    imagesc(community_new_k1(:,:,k)./(lambda_ij_new+1e-1));
                end
                title(['Community ',num2str(k)],'FontSize', 9)
                caxis([0 1]);
            end
            hp4 = get(subplot(4,4,16),'Position')

            colorbar('Position', [hp4(1)+hp4(3)+0.01  hp4(2)  0.015  hp4(2)+hp4(3)*4.1])
            suptitle('Formed overlapping Communities in Symmetric Model')
            fig1=figure(1);
            fig1.Renderer='Painters';

            fig = gcf;
            fig.PaperPositionMode = 'auto'
            fig_pos = fig.PaperPosition;
            fig.PaperSize = [fig_pos(3) fig_pos(4)];

            for k = 1:K_prime
                St_community_new(:,:,k) = ((W_new.*Z_new).*(community_new_k1(:,:,k)./(lambda_ij_new+1e-8))) * [S0_new S_new(:,1:T-1)];
            end
            figure;plot3(St_community_new(1,:,1),St_community_new(1+community_length_row(1),:,2),St_community_new(1+community_length_row(1)+community_length_row(2),:,3))

            for cc = 1:3
                temptemp(:,:,cc)=D_new* St_community_new(:,:,cc);        
            end


            figure
            for i =1:5
                for cc = 1:3
                    subplot(5,4,4*(i-1)+cc)
                    plot(temptemp(i,:,cc))
                    xlim([0 600])
                    if i==1
                        title(['Community ',num2str(cc)],'FontSize', 9)
                    end
                    if cc==1
                        ylabel(['d',num2str(i)],'FontSize', 9)
                        hYLabel = get(gca,'YLabel');
                        set(hYLabel,'rotation',0,'VerticalAlignment','middle')
                       % title(['d',num2str(i)],'FontSize', 9,'position',[-200 0])
                    end
                end
                hhhh= sum(temptemp,3);
                subplot(5,4,4*(i-1)+cc+1)
                plot(hhhh(i,:))
                hold on
                plot(X_recon_avg1(i,:))
                hold on
                plot(X_orig_avg1(i,:))
                xlim([0 600])
                % plot(X_recon_avg1(i,:))
            end

            suptitle('Data reconstruction from each community on each dimension')
            fig1=figure(1);
            fig1.Renderer='Painters';

            fig = gcf;
            fig.PaperPositionMode = 'auto'
            fig_pos = fig.PaperPosition;
            fig.PaperSize = [fig_pos(3) fig_pos(4)];
            for j =1:5
                i = j+5;
                for cc = 1:3

                    subplot(5,4,4*(j-1)+cc)
                    plot(temptemp(i,:,cc))
                    xlim([0 600])
                    if j==1
                        title(['Community ',num2str(cc)],'FontSize', 9)
                    end
                    if cc==1
                        ylabel(['d',num2str(i)],'FontSize', 9)
                        hYLabel = get(gca,'YLabel');
                        set(hYLabel,'rotation',0,'VerticalAlignment','middle')
                       % title(['d',num2str(i)],'FontSize', 9,'position',[-200 0])
                    end

                end
                hhhh= sum(temptemp,3);
                subplot(5,4,4*(j-1)+cc+1)
                plot(hhhh(i,:))
                hold on
                plot(X_recon_avg1(i,:))
                hold on
                plot(X_orig_avg1(i,:))
                xlim([0 600])
                % plot(X_recon_avg1(i,:))
            end

            suptitle('Data reconstruction from each community on each dimension')
            fig1=figure;
            fig1.Renderer='Painters';

            fig = gcf;
            fig.PaperPositionMode = 'auto'
            fig_pos = fig.PaperPosition;
            fig.PaperSize = [fig_pos(3) fig_pos(4)];
        end


    end

    


end









